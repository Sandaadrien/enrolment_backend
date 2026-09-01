import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class RefreshTokenDto {
  @ApiProperty({
    example: '9a3f8c...',
    description: 'Refresh token fourni lors de la connexion',
  })
  @IsString()
  @IsNotEmpty()
  refresh_token!: string;
}
