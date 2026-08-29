import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { EnrolmentModule } from './enrolment/enrolment.module';
import { PrismaModule } from './prisma/prisma.module';
import { AgentModule } from './agent/agent.module';
import { AuthModule } from './auth/auth.module';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    EnrolmentModule,
    PrismaModule,
    AgentModule,
    AuthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
