import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CountryService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.country.findMany({
      orderBy: {
        name: 'asc',
      },
    });
  }

  async findOne(id: string) {
    const country = await this.prisma.country.findUnique({
      where: {
        id,
      },
    });

    if (!country) {
      throw new NotFoundException(`Country with id "${id}" not found`);
    }

    return country;
  }

  async findRegions(countryId: string) {
    return this.prisma.region.findMany({
      where: {
        country_id: countryId,
      },
      orderBy: {
        name: 'asc',
      },
    });
  }
}
