import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

import { AuthService } from './auth.service';
import { PrismaService } from '../prisma/prisma.service';
import { MailService } from '../mail/mail.service';
import { LoginDto } from './dto/login.dto';

jest.mock('bcrypt');

describe('AuthService', () => {
  let service: AuthService;
  let prisma: {
    agent: { findUnique: jest.Mock };
    refresh_token: { create: jest.Mock };
  };
  let jwtService: { signAsync: jest.Mock };
  let mailService: { sendPasswordResetOtp: jest.Mock };

  const agent = {
    id: 'agent-1',
    username: 'agent.ilafy.01',
    password_hash: 'hashed-password',
    id_application_role: 'role-1',
    id_centre: 'centre-1',
  };

  beforeEach(async () => {
    prisma = {
      agent: { findUnique: jest.fn() },
      refresh_token: { create: jest.fn() },
    };
    jwtService = { signAsync: jest.fn() };
    mailService = { sendPasswordResetOtp: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: prisma },
        { provide: JwtService, useValue: jwtService },
        { provide: MailService, useValue: mailService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('login', () => {
    const loginDto: LoginDto = {
      username: 'agent.ilafy.01',
      password: '123456',
    };

    it('should return an access token and the agent when credentials are valid', async () => {
      prisma.agent.findUnique.mockResolvedValue(agent);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      jwtService.signAsync.mockResolvedValue('signed-token');
      prisma.refresh_token.create.mockResolvedValue({ id: 'rt-1' });

      const payload = {
        sub: agent.id,
        username: agent.username,
        roleId: agent.id_application_role,
        centreId: agent.id_centre,
      };

      const result = await service.login(loginDto);

      expect(result.access_token).toBe('signed-token');
      expect(typeof result.refresh_token).toBe('string');
      expect(result.agent).toEqual({
        id: agent.id,
        username: agent.username,
        roleId: agent.id_application_role,
        centreId: agent.id_centre,
      });
      expect(prisma.agent.findUnique).toHaveBeenCalledWith({
        where: { username: loginDto.username },
      });
      expect(jwtService.signAsync).toHaveBeenCalledWith(payload);
    });

    it('should throw UnauthorizedException when the agent does not exist', async () => {
      prisma.agent.findUnique.mockResolvedValue(null);

      await expect(service.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
      expect(jwtService.signAsync).not.toHaveBeenCalled();
    });

    it('should throw UnauthorizedException when the password is invalid', async () => {
      prisma.agent.findUnique.mockResolvedValue(agent);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(service.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
      expect(jwtService.signAsync).not.toHaveBeenCalled();
    });
  });

  describe('getProfile', () => {
    const fullAgent = {
      id: 'agent-1',
      username: 'agent.ilafy.01',
      application_role: {
        id: 'role-1',
        name: 'IA',
        description: 'Agent d\u2019identification',
      },
      centre: {
        id: 'centre-1',
        code: 'CE-01',
        name: 'Centre Est',
      },
      person: {
        id: 'person-1',
        first_name: 'Jean',
        last_name: 'Rakoto',
        date_of_birth: '1990-01-01',
        birth_place: 'Antananarivo',
        sex: 'M',
      },
    };

    it('should return the agent profile with related data', async () => {
      prisma.agent.findUnique.mockResolvedValue(fullAgent);

      await expect(service.getProfile('agent-1')).resolves.toEqual({
        id: fullAgent.id,
        username: fullAgent.username,
        role: {
          id: 'role-1',
          name: 'IA',
          description: 'Agent d\u2019identification',
        },
        centre: {
          id: 'centre-1',
          code: 'CE-01',
          name: 'Centre Est',
        },
        person: {
          id: 'person-1',
          first_name: 'Jean',
          last_name: 'Rakoto',
          date_of_birth: '1990-01-01',
          birth_place: 'Antananarivo',
          sex: 'M',
        },
      });
    });

    it('should throw UnauthorizedException when the agent does not exist', async () => {
      prisma.agent.findUnique.mockResolvedValue(null);

      await expect(service.getProfile('unknown')).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });
});
