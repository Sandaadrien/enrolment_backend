import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

import { relationship_type } from 'generated/prisma/enums';

export class CreateFamilyRelationshipDto {
  @ApiPropertyOptional({
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  @IsOptional()
  @IsUUID()
  related_person_id?: string;

  @ApiPropertyOptional({
    example: 'RAKOTO Jean',
  })
  @IsOptional()
  @IsString()
  related_person_name?: string;

  @ApiProperty({
    enum: relationship_type,
    example: relationship_type.FATHER,
  })
  @IsEnum(relationship_type)
  relationship_type!: relationship_type;
}
