import { IsBoolean, IsNumber, IsOptional, IsString } from 'class-validator';

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateFaceBiometricDto {
  @ApiProperty({
    example: '/uploads/faces/person.jpg',
  })
  @IsString()
  image_file_path!: string;

  @ApiPropertyOptional({
    example: 'FaceNet',
  })
  @IsOptional()
  @IsString()
  model_name?: string;

  @ApiPropertyOptional({
    example: '1.0.0',
  })
  @IsOptional()
  @IsString()
  model_version?: string;

  @ApiProperty({
    example: '[0.123,0.456,0.789]',
  })
  @IsString()
  embeding!: string;

  @ApiProperty({
    example: 98.5,
  })
  @IsNumber()
  quality_score!: number;

  @ApiProperty({
    example: true,
  })
  @IsBoolean()
  face_detected!: boolean;
}
