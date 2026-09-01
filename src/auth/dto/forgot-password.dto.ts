import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty } from 'class-validator';

export class ForgotPasswordDto {
  @ApiProperty({
    example: 'agent@example.com',
    description: 'Adresse email associée au compte',
  })
  @IsEmail()
  @IsNotEmpty()
  email!: string;
}
