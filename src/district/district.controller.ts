import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { DistrictService } from './district.service';

@Controller('districts')
export class DistrictController {
  constructor(private readonly districtService: DistrictService) {}

  @Get()
  findAll() {
    return this.districtService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', new ParseUUIDPipe()) id: string) {
    return this.districtService.findOne(id);
  }

  @Get(':id/communes')
  findCommunes(@Param('id', new ParseUUIDPipe()) id: string) {
    return this.districtService.findCommunes(id);
  }
}
