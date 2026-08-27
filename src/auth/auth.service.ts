import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async login(loginDto: LoginDto) {
    const { username, password } = loginDto;
    const agent = await this.prisma.agent.findUnique({
      where: {
        username,
      },
    });

    if (!agent) {
      throw new UnauthorizedException('Username ou mot de passe incorrect');
    }

    const passwordValid = await bcrypt.compare(password, agent.password_hash);

    if (!passwordValid) {
      throw new UnauthorizedException('Username ou mot de passe incorrect');
    }

    const payload = {
      sub: agent.id,
      username: agent.username,
      roleId: agent.id_application_role,
      centreId: agent.id_centre,
    };

    const accessToken = await this.jwtService.signAsync(payload);

    return {
      access_token: accessToken,
      agent: {
        id: agent.id,
        username: agent.username,
        roleId: agent.id_application_role,
        centreId: agent.id_centre,
      },
    };
  }
}
