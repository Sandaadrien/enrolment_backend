import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { JwtPayload } from './interfaces/jwt-payload.interface';

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

    const payload: JwtPayload = {
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

  async getProfile(agentId: string) {
    const agent = await this.prisma.agent.findUnique({
      where: {
        id: agentId,
      },
      include: {
        application_role: true,
        centre: true,
        person: true,
      },
    });

    if (!agent) {
      throw new UnauthorizedException('Agent introuvable');
    }

    return {
      id: agent.id,
      username: agent.username,

      role: {
        id: agent.application_role.id,
        name: agent.application_role.name,
        description: agent.application_role.description,
      },

      centre: {
        id: agent.centre.id,
        code: agent.centre.code,
        name: agent.centre.name,
      },

      person: {
        id: agent.person.id,
        first_name: agent.person.first_name,
        last_name: agent.person.last_name,
        date_of_birth: agent.person.date_of_birth,
        birth_place: agent.person.birth_place,
        sex: agent.person.sex,
      },
    };
  }
}
