import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CommuneService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.commune.findMany({
      orderBy: {
        name: 'asc',
      },
    });
  }

  async findOne(id: string) {
    const commune = await this.prisma.commune.findUnique({
      where: {
        id,
      },
    });

    if (!commune) {
      throw new NotFoundException(`Commune with id "${id}" not found`);
    }

    return commune;
  }

  async findFokontany(communeId: string) {
    return this.prisma.fokontany.findMany({
      where: {
        commune_id: communeId,
      },
      orderBy: {
        name: 'asc',
      },
    });
  }
}
