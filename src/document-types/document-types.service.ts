import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DocumentTypesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.document_type.findMany({
      orderBy: {
        name: 'asc',
      },
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
  }
}
