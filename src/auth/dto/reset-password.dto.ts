import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, Length } from 'class-validator';

export class ResetPasswordDto {
  @ApiProperty({
    example: '8f7b2c...',
    description: 'Token temporaire obtenu après vérification de l’OTP',
  })
  @IsString()
  @IsNotEmpty()
  reset_token!: string;

  @ApiProperty({
    example: 'NouveauMotDePasse123!',
  })
  @IsString()
  @IsNotEmpty()
  @Length(8, 128)
  new_password!: string;
}
