import { Module } from '@nestjs/common';
import { RecentActivityController } from './recent-activity.controller';
import { RecentActivityService } from './recent-activity.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [RecentActivityController],
  providers: [RecentActivityService],
})
export class RecentActivityModule {}
