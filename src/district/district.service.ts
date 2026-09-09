import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DistrictService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.district.findMany({
      orderBy: {
        name: 'asc',
      },
    });
  }

  async findOne(id: string) {
    const district = await this.prisma.district.findUnique({
      where: {
        id,
      },
    });

    if (!district) {
      throw new NotFoundException(`District with id "${id}" not found`);
    }

    return district;
  }

  async findCommunes(districtId: string) {
    return this.prisma.commune.findMany({
      where: {
        district_id: districtId,
      },
      orderBy: {
        name: 'asc',
      },
    });
  }
}
