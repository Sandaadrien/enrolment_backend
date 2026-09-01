import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({
    example: 'agent.ankadikely.02',
    description: "Nom d'utilisateur de l'agent",
  })
  @IsString()
  @IsNotEmpty()
  username!: string;

  @ApiProperty({
    example: 'abcdefgh',
    description: 'Mot de passe',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  password!: string;
}
