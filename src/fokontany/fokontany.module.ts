import { Module } from '@nestjs/common';
import { FokontanyController } from './fokontany.controller';
import { FokontanyService } from './fokontany.service';

@Module({
  controllers: [FokontanyController],
  providers: [FokontanyService],
})
export class FokontanyModule {}
