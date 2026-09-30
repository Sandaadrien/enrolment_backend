import { Controller, Get, Query } from '@nestjs/common';
import { RecentActivityService } from './recent-activity.service';
import { RecentActivityDto } from './dto/recent-activity.dto';

@Controller('recent-activity')
export class RecentActivityController {
  constructor(private readonly recentActivityService: RecentActivityService) {}

  @Get()
  async getRecentActivity(
    @Query('limit') limit?: string,
  ): Promise<RecentActivityDto[]> {
    const parsedLimit = limit ? Number(limit) : 10;

    return this.recentActivityService.getRecentActivity(parsedLimit);
  }
}
