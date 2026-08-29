import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({
    example: 'agent.ilafy.01',
    description: "Nom d'utilisateur de l'agent",
  })
  @IsString()
  @IsNotEmpty()
  username!: string;

  @ApiProperty({
    example: '123456',
    description: 'Mot de passe',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  password!: string;
}
