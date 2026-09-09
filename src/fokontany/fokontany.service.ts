import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FokontanyService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.fokontany.findMany({
      orderBy: {
        name: 'asc',
      },
    });
  }

  async findOne(id: string) {
    const fokontany = await this.prisma.fokontany.findUnique({
      where: {
        id,
      },
    });

    if (!fokontany) {
      throw new NotFoundException(`Fokontany with id "${id}" not found`);
    }

    return fokontany;
  }
}
