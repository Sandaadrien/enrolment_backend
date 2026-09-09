import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class RegionService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.region.findMany({
      orderBy: {
        name: 'asc',
      },
    });
  }

  async findOne(id: string) {
    const region = await this.prisma.region.findUnique({
      where: {
        id,
      },
    });

    if (!region) {
      throw new NotFoundException(`Region with id "${id}" not found`);
    }

    return region;
  }

  async findDistricts(regionId: string) {
    return this.prisma.district.findMany({
      where: {
        region_id: regionId,
      },
      orderBy: {
        name: 'asc',
      },
    });
  }
}
