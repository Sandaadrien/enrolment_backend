import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { CountryService } from './country.service';

@Controller('countries')
export class CountryController {
  constructor(private readonly countryService: CountryService) {}

  @Get()
  findAll() {
    return this.countryService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', new ParseUUIDPipe()) id: string) {
    return this.countryService.findOne(id);
  }

  @Get(':id/regions')
  findRegions(@Param('id', new ParseUUIDPipe()) id: string) {
    return this.countryService.findRegions(id);
  }
}
