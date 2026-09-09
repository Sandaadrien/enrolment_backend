import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { RegionService } from './region.service';

@Controller('regions')
export class RegionController {
  constructor(private readonly regionService: RegionService) {}

  @Get()
  findAll() {
    return this.regionService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', new ParseUUIDPipe()) id: string) {
    return this.regionService.findOne(id);
  }

  @Get(':id/districts')
  findDistricts(@Param('id', new ParseUUIDPipe()) id: string) {
    return this.regionService.findDistricts(id);
  }
}
