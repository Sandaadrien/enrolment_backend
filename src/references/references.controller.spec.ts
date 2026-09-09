import { Test, TestingModule } from '@nestjs/testing';
import { ReferencesController } from './references.controller';
import { ReferencesService } from './references.service';

describe('ReferencesController', () => {
  let controller: ReferencesController;
  let referencesService: {
    getSexes: jest.Mock;
    getOccupancyTypes: jest.Mock;
    getContactTypes: jest.Mock;
    getRelationshipTypes: jest.Mock;
    getEnrolmentTypes: jest.Mock;
    getNewEnrolmentReferences: jest.Mock;
  };

  beforeEach(async () => {
    referencesService = {
      getSexes: jest.fn(),
      getOccupancyTypes: jest.fn(),
      getContactTypes: jest.fn(),
      getRelationshipTypes: jest.fn(),
      getEnrolmentTypes: jest.fn(),
      getNewEnrolmentReferences: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [ReferencesController],
      providers: [
        {
          provide: ReferencesService,
          useValue: referencesService,
        },
      ],
    }).compile();

    controller = module.get<ReferencesController>(ReferencesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should delegate getSexes to the service', () => {
    const result = [{ value: 'M', label: 'M' }];
    referencesService.getSexes.mockReturnValue(result);

    expect(controller.getSexes()).toBe(result);
    expect(referencesService.getSexes).toHaveBeenCalled();
  });

  it('should delegate getOccupancyTypes to the service', () => {
    const result = [{ value: 'OWNER', label: 'Owner' }];
    referencesService.getOccupancyTypes.mockReturnValue(result);

    expect(controller.getOccupancyTypes()).toBe(result);
    expect(referencesService.getOccupancyTypes).toHaveBeenCalled();
  });

  it('should delegate getContactTypes to the service', () => {
    const result = [{ value: 'phone', label: 'Phone' }];
    referencesService.getContactTypes.mockReturnValue(result);

    expect(controller.getContactTypes()).toBe(result);
    expect(referencesService.getContactTypes).toHaveBeenCalled();
  });

  it('should delegate getRelationshipTypes to the service', () => {
    const result = [{ value: 'FATHER', label: 'Father' }];
    referencesService.getRelationshipTypes.mockReturnValue(result);

    expect(controller.getRelationshipTypes()).toBe(result);
    expect(referencesService.getRelationshipTypes).toHaveBeenCalled();
  });

  it('should delegate getEnrolmentTypes to the service', () => {
    const result = [{ value: 'NEW', label: 'New' }];
    referencesService.getEnrolmentTypes.mockReturnValue(result);

    expect(controller.getEnrolmentTypes()).toBe(result);
    expect(referencesService.getEnrolmentTypes).toHaveBeenCalled();
  });

  it('should delegate getNewEnrolmentReferences to the service', () => {
    const result = { sexes: [] };
    referencesService.getNewEnrolmentReferences.mockReturnValue(result);

    expect(controller.getNewEnrolmentReferences()).toBe(result);
    expect(referencesService.getNewEnrolmentReferences).toHaveBeenCalled();
  });
});
