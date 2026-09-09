import { Controller, Get } from '@nestjs/common';
import { ReferencesService } from './references.service';

@Controller('references')
export class ReferencesController {
  constructor(private readonly referencesService: ReferencesService) {}

  @Get('sexes')
  getSexes() {
    return this.referencesService.getSexes();
  }

  @Get('occupancy-types')
  getOccupancyTypes() {
    return this.referencesService.getOccupancyTypes();
  }

  @Get('contact-types')
  getContactTypes() {
    return this.referencesService.getContactTypes();
  }

  @Get('relationship-types')
  getRelationshipTypes() {
    return this.referencesService.getRelationshipTypes();
  }

  @Get('enrolment-types')
  getEnrolmentTypes() {
    return this.referencesService.getEnrolmentTypes();
  }

  @Get('new-enrolment')
  getNewEnrolmentReferences() {
    return this.referencesService.getNewEnrolmentReferences();
  }
}
