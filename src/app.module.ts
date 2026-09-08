import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { EnrolmentModule } from './enrolment/enrolment.module';
import { PrismaModule } from './prisma/prisma.module';
import { AgentModule } from './agent/agent.module';
import { AuthModule } from './auth/auth.module';
import { ConfigModule } from '@nestjs/config';
import { CountryModule } from './country/country.module';
import { RegionModule } from './region/region.module';
import { FokontanyModule } from './fokontany/fokontany.module';
import { CommuneModule } from './commune/commune.module';
import { DistrictModule } from './district/district.module';
import { FileModule } from './file/file.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    EnrolmentModule,
    PrismaModule,
    AgentModule,
    AuthModule,
    CountryModule,
    RegionModule,
    FokontanyModule,
    CommuneModule,
    DistrictModule,
    FileModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
