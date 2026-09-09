import { Test, TestingModule } from '@nestjs/testing';
import { ReferencesService } from './references.service';

describe('ReferencesService', () => {
  let service: ReferencesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ReferencesService],
    }).compile();

    service = module.get<ReferencesService>(ReferencesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getSexes', () => {
    it('should return a labelled list of sex values', () => {
      expect(service.getSexes()).toEqual([
        { value: 'M', label: 'M' },
        { value: 'F', label: 'F' },
        { value: 'Others', label: 'Others' },
      ]);
    });
  });

  describe('getOccupancyTypes', () => {
    it('should return labelled occupancy types', () => {
      expect(service.getOccupancyTypes()).toEqual([
        { value: 'OWNER', label: 'Owner' },
        { value: 'TENANT', label: 'Tenant' },
        { value: 'FAMILY', label: 'Family' },
        { value: 'OTHERS', label: 'Others' },
      ]);
    });
  });

  describe('getContactTypes', () => {
    it('should return labelled contact types', () => {
      expect(service.getContactTypes()).toEqual([
        { value: 'phone', label: 'Phone' },
        { value: 'email', label: 'Email' },
      ]);
    });
  });

  describe('getRelationshipTypes', () => {
    it('should return labelled relationship types', () => {
      expect(service.getRelationshipTypes()).toEqual([
        { value: 'FATHER', label: 'Father' },
        { value: 'MOTHER', label: 'Mother' },
        { value: 'SPOUSE', label: 'Spouse' },
      ]);
    });
  });

  describe('getEnrolmentTypes', () => {
    it('should return labelled enrolment types', () => {
      expect(service.getEnrolmentTypes()).toEqual([
        { value: 'NEW', label: 'New' },
        { value: 'UPDATE', label: 'Update' },
        { value: 'CORRECTION', label: 'Correction' },
      ]);
    });
  });

  describe('getNewEnrolmentReferences', () => {
    it('should aggregate all references', () => {
      const result = service.getNewEnrolmentReferences();

      expect(result.sexes).toHaveLength(3);
      expect(result.occupancy_types).toHaveLength(4);
      expect(result.contact_types).toHaveLength(2);
      expect(result.relationship_types).toHaveLength(3);
      expect(result.enrolment_types).toHaveLength(3);
    });
  });
});
