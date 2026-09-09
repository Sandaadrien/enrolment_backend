import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import { CreateEnrolmentDto } from './dto/create-enrolment.dto';

import { Prisma } from 'generated/prisma/client';

@Injectable()
export class EnrolmentService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateEnrolmentDto, agentId: string) {
    return this.prisma.$transaction(async (tx) => {
      /*
       * ==========================================
       * 1. Vérifier l'agent
       * ==========================================
       */

      const agent = await tx.agent.findUnique({
        where: {
          id: agentId,
        },
      });

      if (!agent) {
        throw new NotFoundException('Agent not found');
      }

      /*
       * ==========================================
       * 2. Vérifier le pays de naissance
       * ==========================================
       */

      const country = await tx.country.findUnique({
        where: {
          id: dto.person.country_of_birth_id,
        },
      });

      if (!country) {
        throw new NotFoundException('Country of birth not found');
      }

      /*
       * ==========================================
       * 3. Vérifier le fokontany
       * ==========================================
       */

      const fokontany = await tx.fokontany.findUnique({
        where: {
          id: dto.address.fokontany_id,
        },
      });

      if (!fokontany) {
        throw new NotFoundException('Fokontany not found');
      }

      /*
       * ==========================================
       * 4. Créer PERSON
       * ==========================================
       */

      const person = await tx.person.create({
        data: {
          first_name: dto.person.first_name,

          last_name: dto.person.last_name,

          date_of_birth: dto.person.date_of_birth
            ? new Date(dto.person.date_of_birth)
            : undefined,

          birth_place: dto.person.birth_place,

          id_country_of_birth: dto.person.country_of_birth_id,

          sex: dto.person.sex,
        },
      });

      /*
       * ==========================================
       * 5. Générer le numéro national
       * ==========================================
       */

      const nationalUniqueId = await this.generateNationalUniqueId(tx);

      /*
       * ==========================================
       * 6. Créer CITIZEN
       * ==========================================
       */

      const citizen = await tx.citizen.create({
        data: {
          person_id: person.id,

          national_unique_id: nationalUniqueId,
        },
      });

      /*
       * ==========================================
       * 7. Générer application_id
       * ==========================================
       */

      const applicationId = this.generateApplicationId();

      /*
       * ==========================================
       * 8. Créer ENROLMENT
       * ==========================================
       */

      const enrolment = await tx.enrolment.create({
        data: {
          agent_id: agent.id,

          citizen_id: citizen.id,

          application_id: applicationId,

          created_offline: dto.created_offline ?? false,

          sync_status: false,

          enrolment_type: dto.enrolment_type ?? 'NEW',
        },
      });

      /*
       * ==========================================
       * 9. Créer ADDRESS
       * ==========================================
       */

      await tx.address.create({
        data: {
          id_person: person.id,

          id_fokontany: dto.address.fokontany_id,

          house_number: dto.address.house_number,

          occupancy_type: dto.address.occupancy_type,
        },
      });

      /*
       * ==========================================
       * 10. Créer CONTACTS
       * ==========================================
       */

      if (dto.contacts?.length) {
        await tx.contact_method.createMany({
          data: dto.contacts.map((contact) => ({
            person_id: person.id,

            type: contact.type,

            value: contact.value,

            is_primary: contact.is_primary ?? false,

            is_verified: contact.is_verified ?? false,
          })),
        });
      }

      /*
       * ==========================================
       * 11. Relations familiales
       * ==========================================
       */

      if (dto.relationships?.length) {
        const relationshipsData: Prisma.family_relationshipsCreateManyInput[] =
          [];

        for (const relationship of dto.relationships) {
          let relatedPersonId: string | null = null;

          if (relationship.related_person_id) {
            const relatedCitizen = await tx.citizen.findUnique({
              where: {
                id: relationship.related_person_id,
              },
            });

            if (relatedCitizen) {
              relatedPersonId = relatedCitizen.id;
            } else {
              console.log(
                `Citizen ${relationship.related_person_id} not found. ` +
                  `Relationship will be stored with name only.`,
              );
            }
          }

          relationshipsData.push({
            citizen_id: citizen.id,
            related_person_id: relatedPersonId,
            related_person_name: relationship.related_person_name ?? null,
            relationship_type: relationship.relationship_type,
          });
        }

        await tx.family_relationships.createMany({
          data: relationshipsData,
        });
      }

      /*
       * ==========================================
       * 12. Vérifier les types de documents
       * ==========================================
       */

      for (const document of dto.documents) {
        const documentType = await tx.document_type.findUnique({
          where: {
            id: document.document_type_id,
          },
        });

        if (!documentType) {
          throw new NotFoundException(
            `Document type ${document.document_type_id} not found`,
          );
        }
      }

      /*
       * ==========================================
       * 13. Créer les DOCUMENTS
       * ==========================================
       */

      await tx.document.createMany({
        data: dto.documents.map((document) => ({
          enrolment_id: enrolment.id,

          document_type_id: document.document_type_id,

          front_file_path: document.front_file_path,

          back_file_path: document.back_file_path,
        })),
      });

      /*
       * ==========================================
       * 14. Créer les BIOMÉTRIES
       * ==========================================
       */

      if (dto.face_biometrics?.length) {
        await tx.face_biometrics.createMany({
          data: dto.face_biometrics.map((biometric) => ({
            enrolment_id: enrolment.id,

            image_file_path: biometric.image_file_path,

            model_name: biometric.model_name ?? 'unknown',

            model_version: biometric.model_version ?? 'unknown',

            embeding: biometric.embeding,

            quality_score: biometric.quality_score,

            face_detected: biometric.face_detected,
          })),
        });
      }

      /*
       * ==========================================
       * 15. Retour
       * ==========================================
       */

      return {
        enrolment_id: enrolment.id,

        application_id: enrolment.application_id,

        citizen_id: citizen.id,

        national_unique_id: citizen.national_unique_id,

        status: enrolment.enrolment_type,
      };
    });
  }

  /*
   * ==========================================
   * Génération application_id
   * ==========================================
   */

  private generateApplicationId(): string {
    return `APP-${Date.now()}-${Math.floor(Math.random() * 100000)}`;
  }

  /*
   * ==========================================
   * Génération national_unique_id
   * ==========================================
   */

  private async generateNationalUniqueId(
    tx: Prisma.TransactionClient,
  ): Promise<string> {
    let nationalUniqueId = '';
    let exists = true;

    while (exists) {
      nationalUniqueId = `NUI-${Date.now()}-${Math.floor(
        Math.random() * 1000000,
      )}`;

      const existing = await tx.citizen.findFirst({
        where: {
          national_unique_id: nationalUniqueId,
        },
      });

      exists = !!existing;
    }

    return nationalUniqueId;
  }
}
