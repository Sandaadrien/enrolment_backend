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
    example: '33cc35a3-60ff-482c-9fc3-0e4dd7b7c60f',
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
