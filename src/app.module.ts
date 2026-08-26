import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { EnrolmentModule } from './enrolment/enrolment.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [EnrolmentModule, PrismaModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
