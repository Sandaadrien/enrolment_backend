import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';

import { Request } from 'express';

import { CreateEnrolmentDto } from './dto/create-enrolment.dto';
import { EnrolmentService } from './enrolment.service';
import { ApiBearerAuth } from '@nestjs/swagger';

import { JwtAuthGuard } from '../auth/guards/jwt-auth.guards';

@Controller('enrolments')
export class EnrolmentController {
  constructor(private readonly enrolmentService: EnrolmentService) {}

  @Post()
  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  create(@Body() dto: CreateEnrolmentDto, @Req() req: Request) {
    const user = req.user as {
      sub: string;
    };
    return this.enrolmentService.create(dto, user.sub);
  }
}
