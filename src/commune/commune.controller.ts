import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { CommuneService } from './commune.service';

@Controller('communes')
export class CommuneController {
  constructor(private readonly communeService: CommuneService) {}

  @Get()
  findAll() {
    return this.communeService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', new ParseUUIDPipe()) id: string) {
    return this.communeService.findOne(id);
  }

  @Get(':id/fokontany')
  findFokontany(@Param('id', new ParseUUIDPipe()) id: string) {
    return this.communeService.findFokontany(id);
  }
}
