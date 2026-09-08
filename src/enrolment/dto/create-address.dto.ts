import { IsEnum, IsString, IsUUID } from 'class-validator';

import { ApiProperty } from '@nestjs/swagger';

import { occupancy_type } from 'generated/prisma/enums';

export class CreateAddressDto {
  @ApiProperty({
    example: '12B',
  })
  @IsString()
  house_number!: string;

  @ApiProperty({
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  @IsUUID()
  fokontany_id!: string;

  @ApiProperty({
    enum: occupancy_type,
    example: occupancy_type.OWNER,
  })
  @IsEnum(occupancy_type)
  occupancy_type!: occupancy_type;
}
