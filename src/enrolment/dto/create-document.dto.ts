import { IsOptional, IsString, IsUUID } from 'class-validator';

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateDocumentDto {
  @ApiProperty({
    example: '756c47a4-0409-4d0d-8aa9-125c05b76813',
  })
  @IsUUID()
  document_type_id!: string;

  @ApiProperty({
    example: '/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png',
  })
  @IsString()
  front_file_path!: string;

  @ApiPropertyOptional({
    example: '/uploads/documents/7c55adf5-6c15-4705-a37a-40edee4afc83.png',
  })
  @IsOptional()
  @IsString()
  back_file_path?: string;
}
