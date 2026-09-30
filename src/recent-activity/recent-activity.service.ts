import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RecentActivityDto } from './dto/recent-activity.dto';

@Injectable()
export class RecentActivityService {
  constructor(private readonly prisma: PrismaService) {}

  async getRecentActivity(limit = 10): Promise<RecentActivityDto[]> {
    const enrolments = await this.prisma.enrolment.findMany({
      take: limit,

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

    return enrolments.map((enrolment) => {
      const person = enrolment.citizen.person;

      return {
        applicantName: [person.first_name, person.last_name]
          .filter(Boolean)
          .join(' '),

        idReference: enrolment.application_id,

        time: enrolment.created_at.toLocaleTimeString('en-US', {
          hour: '2-digit',
          minute: '2-digit',
          hour12: true,
        }),

        status: enrolment.sync_status ? 'Synced' : 'Local Only',
      };
    });
  }
}
