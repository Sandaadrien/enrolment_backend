import { Test, TestingModule } from '@nestjs/testing';
import { EnrolmentController } from './enrolment.controller';
import { EnrolmentService } from './enrolment.service';

describe('EnrolmentController', () => {
  let controller: EnrolmentController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [EnrolmentController],
      providers: [EnrolmentService],
    })
      .overrideProvider(EnrolmentService)
      .useValue({})
      .compile();

    controller = module.get<EnrolmentController>(EnrolmentController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
