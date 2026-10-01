import { Test, TestingModule } from '@nestjs/testing';
import { DashboardService } from './dashboard.service';
import { PrismaService } from '../prisma/prisma.service';

type EnrolmentCountArgs = {
  where: {
    created_at?: { gte: Date; lt: Date };
    sync_status?: boolean;
  };
};

type EnrolmentRecord = {
  application_id: string;
  created_at: Date;
  sync_status: boolean;
  citizen: { person: { first_name: string | null; last_name: string | null } };
};

type EnrolmentPrisma = {
  enrolment: {
    count: jest.Mock<Promise<number>, [EnrolmentCountArgs]>;
    findMany: jest.Mock<Promise<EnrolmentRecord[]>, [unknown]>;
  };
};

describe('DashboardService', () => {
  let service: DashboardService;
  let prisma: EnrolmentPrisma;

  beforeEach(async () => {
    prisma = {
      enrolment: {
        count: jest.fn<Promise<number>, [EnrolmentCountArgs]>(),
        findMany: jest.fn<Promise<EnrolmentRecord[]>, [unknown]>(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DashboardService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<DashboardService>(DashboardService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getDashboard', () => {
    beforeEach(() => {
      prisma.enrolment.count.mockResolvedValueOnce(3).mockResolvedValueOnce(7);
      prisma.enrolment.findMany.mockResolvedValue([
        {
          application_id: 'APP-001',
          created_at: new Date(2026, 0, 15, 14, 5, 0),
          sync_status: true,
          citizen: {
            person: { first_name: 'Rakoto', last_name: 'Rasoanaivo' },
          },
        },
        {
          application_id: 'APP-002',
          created_at: new Date(2026, 0, 15, 9, 30, 0),
          sync_status: false,
          citizen: { person: { first_name: 'Ny', last_name: null } },
        },
      ]);
    });

    it('should return the counts as stats', async () => {
      const result = await service.getDashboard();

      expect(result.stats).toEqual({
        enrolmentsToday: 3,
        pendingSync: 7,
      });
    });

    it('should count enrolments created today within a one day window', async () => {
      await service.getDashboard();

      const createdAt = prisma.enrolment.count.mock.calls[0][0].where.created_at;

      expect(createdAt).toBeDefined();
      expect(createdAt!.gte.getHours()).toBe(0);
      expect(createdAt!.gte.getMinutes()).toBe(0);
      expect(createdAt!.gte.getSeconds()).toBe(0);
      expect(createdAt!.gte.getMilliseconds()).toBe(0);
      expect(createdAt!.lt.getTime()).toBeGreaterThan(createdAt!.gte.getTime());
      expect(createdAt!.lt.getDate()).toBe(createdAt!.gte.getDate() + 1);
    });

    it('should count enrolments that are not synchronized', async () => {
      await service.getDashboard();

      expect(prisma.enrolment.count).toHaveBeenCalledTimes(2);
      expect(prisma.enrolment.count.mock.calls[1][0]).toEqual({
        where: { sync_status: false },
      });
    });

    it('should fetch at most the 10 most recent enrolments', async () => {
      await service.getDashboard();

      expect(prisma.enrolment.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          take: 10,
          orderBy: { created_at: 'desc' },
        }),
      );
    });

    it('should map enrolments to recent activity items', async () => {
      const result = await service.getDashboard();

      expect(result.recentActivity).toEqual([
        {
          applicantName: 'Rakoto Rasoanaivo',
          id: 'APP-001',
          reference: 'APP-001',
          time: '02:05 PM',
          status: 'synced',
        },
        {
          applicantName: 'Ny',
          id: 'APP-002',
          reference: 'APP-002',
          time: '09:30 AM',
          status: 'local-only',
        },
      ]);
    });

    it('should return an empty activity list when there is no enrolment', async () => {
      prisma.enrolment.count.mockReset().mockResolvedValue(0);
      prisma.enrolment.findMany.mockResolvedValue([]);

      const result = await service.getDashboard();

      expect(result.recentActivity).toEqual([]);
      expect(result.stats).toEqual({
        enrolmentsToday: 0,
        pendingSync: 0,
      });
    });
  });
});