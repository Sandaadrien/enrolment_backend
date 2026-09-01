import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { JwtPayload } from './interfaces/jwt-payload.interface';
import { randomBytes, randomInt, createHash } from 'crypto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';

import { ChangePasswordDto } from './dto/change-password.dto';
import { VerifyForgotPasswordDto } from './dto/verify-forgot-password.dto';
import { MailService } from '../mail/mail.service';
import { ResetPasswordDto } from './dto/reset-password.dto';

/* 
├── auth
│   ├── login
│   ├── getProfile
│   ├── refresh
│   ├── logout
|   ├── logoutAll
│   ├── changePassword
│   └── changePassword
*/
@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly mailService: MailService,
  ) {}
  private generateRefreshToken(): string {
    return randomBytes(64).toString('hex');
  }

  private hashRefreshToken(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }

  /* -------------------------------------------------- */
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

    // Refresh token
    const refreshToken = this.generateRefreshToken();
    const refreshTokenHash = this.hashRefreshToken(refreshToken);

    // Durée : 7 jours
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    await this.prisma.refresh_token.create({
      data: {
        agent_id: agent.id,
        token_hash: refreshTokenHash,
        expires_at: expiresAt,
      },
    });

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
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

  async refresh(refreshToken: string) {
    const refreshTokenHash = this.hashRefreshToken(refreshToken);

    const storedToken = await this.prisma.refresh_token.findUnique({
      where: {
        token_hash: refreshTokenHash,
      },
    });

    if (!storedToken) {
      throw new UnauthorizedException('Refresh token invalide');
    }

    if (storedToken.revoked_at) {
      throw new UnauthorizedException('Refresh token révoqué');
    }

    if (storedToken.expires_at <= new Date()) {
      throw new UnauthorizedException('Refresh token expiré');
    }

    const agent = await this.prisma.agent.findUnique({
      where: {
        id: storedToken.agent_id,
      },
    });

    if (!agent) {
      throw new UnauthorizedException('Agent introuvable');
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
    };
  }

  async logout(refreshToken: string) {
    const refreshTokenHash = this.hashRefreshToken(refreshToken);

    const storedToken = await this.prisma.refresh_token.findUnique({
      where: {
        token_hash: refreshTokenHash,
      },
    });

    if (!storedToken) {
      throw new UnauthorizedException('Refresh token invalide');
    }

    if (storedToken.revoked_at) {
      return {
        message: 'Session déjà déconnectée',
      };
    }

    await this.prisma.refresh_token.update({
      where: {
        id: storedToken.id,
      },
      data: {
        revoked_at: new Date(),
      },
    });

    return {
      message: 'Déconnexion réussie',
    };
  }

  async logoutAll(agentId: string) {
    await this.prisma.refresh_token.updateMany({
      where: {
        agent_id: agentId,
        revoked_at: null,
      },
      data: {
        revoked_at: new Date(),
      },
    });

    return {
      message: 'Toutes les sessions ont été déconnectées',
    };
  }

  async changePassword(agentId: string, changePasswordDto: ChangePasswordDto) {
    const agent = await this.prisma.agent.findUnique({
      where: {
        id: agentId,
      },
    });

    if (!agent) {
      throw new UnauthorizedException('Agent introuvable');
    }

    const currentPasswordValid = await bcrypt.compare(
      changePasswordDto.current_password,
      agent.password_hash,
    );

    if (!currentPasswordValid) {
      throw new UnauthorizedException('Mot de passe actuel incorrect');
    }

    const samePassword = await bcrypt.compare(
      changePasswordDto.new_password,
      agent.password_hash,
    );

    if (samePassword) {
      throw new UnauthorizedException(
        'Le nouveau mot de passe doit être différent',
      );
    }

    const newPasswordHash = await bcrypt.hash(
      changePasswordDto.new_password,
      12,
    );

    await this.prisma.$transaction(async (tx) => {
      await tx.agent.update({
        where: {
          id: agentId,
        },
        data: {
          password_hash: newPasswordHash,
        },
      });

      await tx.refresh_token.updateMany({
        where: {
          agent_id: agentId,
          revoked_at: null,
        },
        data: {
          revoked_at: new Date(),
        },
      });
    });

    return {
      message: 'Mot de passe modifié avec succès',
    };
  }

  async forgotPassword(forgotPasswordDto: ForgotPasswordDto) {
    const email = forgotPasswordDto.email.trim().toLowerCase();

    const contact = await this.prisma.contact_method.findFirst({
      where: {
        value: email,
        type: 'email',
        is_verified: true,
        person: {
          agent: {
            some: {},
          },
        },
      },
      include: {
        person: {
          include: {
            agent: true,
          },
        },
      },
    });

    // Toujours retourner la même réponse
    if (!contact || contact.person.agent.length === 0) {
      return {
        message:
          'Si un compte correspond à cette adresse email, un code a été envoyé.',
      };
    }

    const agent = contact.person.agent[0];

    // Invalider les anciens OTP
    await this.prisma.password_reset_otp.updateMany({
      where: {
        agent_id: agent.id,
        used_at: null,
      },
      data: {
        used_at: new Date(),
      },
    });

    const otp = randomInt(100000, 1000000).toString();

    const otpHash = createHash('sha256').update(otp).digest('hex');

    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await this.prisma.password_reset_otp.create({
      data: {
        agent_id: agent.id,
        otp_hash: otpHash,
        expires_at: expiresAt,
      },
    });

    await this.mailService.sendPasswordResetOtp(email, otp);

    return {
      message:
        'Si un compte correspond à cette adresse email, un code a été envoyé.',
    };
  }

  async verifyForgotPassword(verifyDto: VerifyForgotPasswordDto) {
    const email = verifyDto.email.trim().toLowerCase();

    const contact = await this.prisma.contact_method.findFirst({
      where: {
        value: email,
        type: 'email',
        is_verified: true,
        person: {
          agent: {
            some: {},
          },
        },
      },
      include: {
        person: {
          include: {
            agent: true,
          },
        },
      },
    });

    if (!contact || contact.person.agent.length === 0) {
      throw new UnauthorizedException('Code OTP invalide ou expiré');
    }

    const agent = contact.person.agent[0];

    const otpRecord = await this.prisma.password_reset_otp.findFirst({
      where: {
        agent_id: agent.id,
        used_at: null,
      },
      orderBy: {
        created_at: 'desc',
      },
    });

    if (!otpRecord) {
      throw new UnauthorizedException('Code OTP invalide ou expiré');
    }

    if (otpRecord.expires_at <= new Date()) {
      throw new UnauthorizedException('Code OTP invalide ou expiré');
    }

    // Limite de tentatives
    if (otpRecord.attempts >= 5) {
      throw new UnauthorizedException('Nombre maximum de tentatives atteint');
    }

    const otpHash = createHash('sha256').update(verifyDto.otp).digest('hex');

    if (otpHash !== otpRecord.otp_hash) {
      await this.prisma.password_reset_otp.update({
        where: {
          id: otpRecord.id,
        },
        data: {
          attempts: {
            increment: 1,
          },
        },
      });

      throw new UnauthorizedException('Code OTP invalide ou expiré');
    }

    // OTP valide : on le consomme
    await this.prisma.password_reset_otp.update({
      where: {
        id: otpRecord.id,
      },
      data: {
        used_at: new Date(),
      },
    });

    // Génération du token de reset
    const resetToken = randomBytes(64).toString('hex');

    const resetTokenHash = this.hashRefreshToken(resetToken);

    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

    await this.prisma.password_reset_token.create({
      data: {
        agent_id: agent.id,
        token_hash: resetTokenHash,
        expires_at: expiresAt,
      },
    });

    return {
      reset_token: resetToken,
      expires_in: 600,
    };
  }

  async resetPassword(resetPasswordDto: ResetPasswordDto) {
    const resetTokenHash = this.hashRefreshToken(resetPasswordDto.reset_token);

    const resetToken = await this.prisma.password_reset_token.findUnique({
      where: {
        token_hash: resetTokenHash,
      },
    });

    if (!resetToken) {
      throw new UnauthorizedException('Token de réinitialisation invalide');
    }

    if (resetToken.used_at) {
      throw new UnauthorizedException('Token de réinitialisation déjà utilisé');
    }

    if (resetToken.expires_at <= new Date()) {
      throw new UnauthorizedException('Token de réinitialisation expiré');
    }
    const agent = await this.prisma.agent.findUnique({
      where: {
        id: resetToken.agent_id,
      },
    });

    if (!agent) {
      throw new UnauthorizedException('Agent introuvable');
    }
    const samePassword = await bcrypt.compare(
      resetPasswordDto.new_password,
      agent.password_hash,
    );

    if (samePassword) {
      throw new UnauthorizedException(
        'Le nouveau mot de passe doit être différent',
      );
    }

    const newPasswordHash = await bcrypt.hash(
      resetPasswordDto.new_password,
      12,
    );

    await this.prisma.$transaction(async (tx) => {
      await tx.agent.update({
        where: {
          id: agent.id,
        },
        data: {
          password_hash: newPasswordHash,
        },
      });

      // Invalider le reset token
      await tx.password_reset_token.update({
        where: {
          id: resetToken.id,
        },
        data: {
          used_at: new Date(),
        },
      });

      // Déconnecter toutes les sessions
      await tx.refresh_token.updateMany({
        where: {
          agent_id: agent.id,
          revoked_at: null,
        },
        data: {
          revoked_at: new Date(),
        },
      });

      // Invalider les OTP restants
      await tx.password_reset_otp.updateMany({
        where: {
          agent_id: agent.id,
          used_at: null,
        },
        data: {
          used_at: new Date(),
        },
      });
    });

    return {
      message: 'Mot de passe réinitialisé avec succès',
    };
  }
}
