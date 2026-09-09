import { IsOptional, IsString, IsUUID } from 'class-validator';

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateDocumentDto {
  @ApiProperty({
    example: '6851e3d4-ae17-4a93-a48e-1853a596367d',
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
