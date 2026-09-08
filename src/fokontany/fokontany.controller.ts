import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { FokontanyService } from './fokontany.service';

@Controller('fokontany')
export class FokontanyController {
  constructor(private readonly fokontanyService: FokontanyService) {}

  @Get()
  findAll() {
    return this.fokontanyService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', new ParseUUIDPipe()) id: string) {
    return this.fokontanyService.findOne(id);
  }
}
