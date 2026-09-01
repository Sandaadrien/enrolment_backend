import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class ChangePasswordDto {
  @ApiProperty({
    example: '12345678',
    description: 'Mot de passe actuel',
  })
  @IsString()
  @IsNotEmpty()
  current_password!: string;

  @ApiProperty({
    example: 'NouveauMotDePasse123!',
    description: 'Nouveau mot de passe',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  new_password!: string;
}
