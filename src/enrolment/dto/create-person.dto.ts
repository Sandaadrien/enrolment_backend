import {
  IsDateString,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

import { sex } from 'generated/prisma/enums';

export class CreatePersonDto {
  @ApiPropertyOptional({
    example: 'Jean',
  })
  @IsOptional()
  @IsString()
  first_name?: string;

  @ApiProperty({
    example: 'RAKOTO',
  })
  @IsString()
  last_name!: string;

  @ApiPropertyOptional({
    example: '1995-06-15',
  })
  @IsOptional()
  @IsDateString()
  date_of_birth?: string;

  @ApiPropertyOptional({
    example: 'Antananarivo',
  })
  @IsOptional()
  @IsString()
  birth_place?: string;

  @ApiProperty({
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  @IsUUID()
  country_of_birth_id!: string;

  @ApiProperty({
    enum: sex,
    example: sex.M,
  })
  @IsEnum(sex)
  sex!: sex;
}
