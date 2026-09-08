import { IsOptional, IsString, IsUUID } from 'class-validator';

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateDocumentDto {
  @ApiProperty({
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  @IsUUID()
  document_type_id!: string;

  @ApiProperty({
    example: '/uploads/documents/abc.jpg',
  })
  @IsString()
  front_file_path!: string;

  @ApiPropertyOptional({
    example: '/uploads/documents/abc-back.jpg',
  })
  @IsOptional()
  @IsString()
  back_file_path?: string;
}
