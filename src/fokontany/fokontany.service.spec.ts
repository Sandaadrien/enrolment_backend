import { Test, TestingModule } from '@nestjs/testing';
import { FokontanyService } from './fokontany.service';
import { PrismaService } from '../prisma/prisma.service';

describe('FokontanyService', () => {
  let service: FokontanyService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FokontanyService,
        {
          provide: PrismaService,
          useValue: {},
        },
      ],
    }).compile();

    service = module.get<FokontanyService>(FokontanyService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
