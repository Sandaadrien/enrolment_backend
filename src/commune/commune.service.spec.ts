import { Test, TestingModule } from '@nestjs/testing';
import { CommuneService } from './commune.service';
import { PrismaService } from '../prisma/prisma.service';

describe('CommuneService', () => {
  let service: CommuneService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CommuneService,
        {
          provide: PrismaService,
          useValue: {},
        },
      ],
    }).compile();

    service = module.get<CommuneService>(CommuneService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
