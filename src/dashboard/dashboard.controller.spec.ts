import { Test, TestingModule } from '@nestjs/testing';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';

describe('DashboardController', () => {
  let controller: DashboardController;
  let service: { getDashboard: jest.Mock };

  beforeEach(async () => {
    service = {
      getDashboard: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [DashboardController],
      providers: [
        {
          provide: DashboardService,
          useValue: service,
        },
      ],
    }).compile();

    controller = module.get<DashboardController>(DashboardController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getDashboard', () => {
    it('should return the dashboard built by the service', async () => {
      const dashboard = {
        stats: { enrolmentsToday: 1, pendingSync: 2 },
        recentActivity: [],
      };

      service.getDashboard.mockResolvedValue(dashboard);

      expect(await controller.getDashboard()).toEqual(dashboard);
      expect(service.getDashboard).toHaveBeenCalledTimes(1);
    });
  });
});