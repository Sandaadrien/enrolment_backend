import { Test, TestingModule } from '@nestjs/testing';
import { DocumentTypesController } from './document-types.controller';
import { DocumentTypesService } from './document-types.service';

describe('DocumentTypesController', () => {
  let controller: DocumentTypesController;
  let documentTypesService: { findAll: jest.Mock };

  beforeEach(async () => {
    documentTypesService = {
      findAll: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [DocumentTypesController],
      providers: [
        {
          provide: DocumentTypesService,
          useValue: documentTypesService,
        },
      ],
    }).compile();

    controller = module.get<DocumentTypesController>(DocumentTypesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should delegate findAll to the service', async () => {
    const result = [{ id: 'doc-1', name: 'Passeport' }];
    documentTypesService.findAll.mockResolvedValue(result);

    await expect(controller.findAll()).resolves.toBe(result);
    expect(documentTypesService.findAll).toHaveBeenCalled();
  });
});
