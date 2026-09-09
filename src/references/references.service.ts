import { Injectable } from '@nestjs/common';
import {
  contact_type,
  enrolment_type,
  occupancy_type,
  relationship_type,
  sex,
} from 'generated/prisma/enums';

@Injectable()
export class ReferencesService {
  getSexes() {
    return Object.values(sex).map((value) => ({
      value,
      label: this.getLabel(value),
    }));
  }

  getOccupancyTypes() {
    return Object.values(occupancy_type).map((value) => ({
      value,
      label: this.getLabel(value),
    }));
  }

  getContactTypes() {
    return Object.values(contact_type).map((value) => ({
      value,
      label: this.getLabel(value),
    }));
  }

  getRelationshipTypes() {
    return Object.values(relationship_type).map((value) => ({
      value,
      label: this.getLabel(value),
    }));
  }

  getEnrolmentTypes() {
    return Object.values(enrolment_type).map((value) => ({
      value,
      label: this.getLabel(value),
    }));
  }

  getNewEnrolmentReferences() {
    return {
      sexes: this.getSexes(),
      occupancy_types: this.getOccupancyTypes(),
      contact_types: this.getContactTypes(),
      relationship_types: this.getRelationshipTypes(),
      enrolment_types: this.getEnrolmentTypes(),
    };
  }

  private getLabel(value: string): string {
    return value
      .replace(/_/g, ' ')
      .toLowerCase()
      .replace(/\b\w/g, (char) => char.toUpperCase());
  }
}
