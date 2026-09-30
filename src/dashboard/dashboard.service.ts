import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { DashboardDto, RecentActivityDto } from './dto/dashboard.dto';

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async getDashboard(): Promise<DashboardDto> {
    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);

    const startOfTomorrow = new Date(startOfToday);
    startOfTomorrow.setDate(startOfTomorrow.getDate() + 1);

    // Nombre d'enrôlements créés aujourd'hui
    const enrolmentsToday = await this.prisma.enrolment.count({
      where: {
        created_at: {
          gte: startOfToday,
          lt: startOfTomorrow,
        },
      },
    });

    // Nombre de dossiers qui ne sont pas encore synchronisés
    const pendingSync = await this.prisma.enrolment.count({
      where: {
        sync_status: false,
      },
    });

    // Les 10 dernières activités
    const enrolments = await this.prisma.enrolment.findMany({
      take: 10,

      orderBy: {
        created_at: 'desc',
      },

      select: {
        application_id: true,
        created_at: true,
        sync_status: true,

        citizen: {
          select: {
            person: {
              select: {
                first_name: true,
                last_name: true,
              },
            },
          },
        },
      },
    });

    const recentActivity: RecentActivityDto[] = enrolments.map((enrolment) => {
      const person = enrolment.citizen.person;

      const applicantName = [person.first_name, person.last_name]
        .filter(Boolean)
        .join(' ');

      return {
        applicantName,

        idReference: enrolment.application_id,

        time: enrolment.created_at.toLocaleTimeString('en-US', {
          hour: '2-digit',
          minute: '2-digit',
          hour12: true,
        }),

        status: enrolment.sync_status ? 'Synced' : 'Local Only',
      };
    });

    return {
      enrolmentsToday,
      pendingSync,
      pendingSyncLabel: 'dossiers',
      recentActivity,
    };
  }
}
