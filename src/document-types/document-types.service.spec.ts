import { Test, TestingModule } from '@nestjs/testing';
import { DocumentTypesService } from './document-types.service';
import { PrismaService } from '../prisma/prisma.service';

describe('DocumentTypesService', () => {
  let service: DocumentTypesService;
  let prisma: {
    document_type: { findMany: jest.Mock };
  };

  beforeEach(async () => {
    prisma = {
      document_type: { findMany: jest.fn() },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DocumentTypesService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<DocumentTypesService>(DocumentTypesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return document types ordered by name', async () => {
      const result = [
        {
          id: 'doc-1',
          name: 'Passeport',
          description: 'Passeport',
          evidence_strength: 'STRONG',
          requires_mrz: true,
          supports_ocr: true,
          requires_original: true,
        },
      ];
      prisma.document_type.findMany.mockResolvedValue(result);

      await expect(service.findAll()).resolves.toBe(result);
      expect(prisma.document_type.findMany).toHaveBeenCalledWith({
        orderBy: { name: 'asc' },
        select: {
          id: true,
          name: true,
          description: true,
          evidence_strength: true,
          requires_mrz: true,
          supports_ocr: true,
          requires_original: true,
        },
      });
    });
  });
});
