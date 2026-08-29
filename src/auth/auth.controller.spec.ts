import { Test, TestingModule } from '@nestjs/testing';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { JwtPayload } from './interfaces/jwt-payload.interface';

describe('AuthController', () => {
  let controller: AuthController;
  let authService: { login: jest.Mock; getProfile: jest.Mock };

  beforeEach(async () => {
    authService = {
      login: jest.fn(),
      getProfile: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [{ provide: AuthService, useValue: authService }],
    }).compile();

    controller = module.get<AuthController>(AuthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('login', () => {
    it('should delegate to AuthService and return its result', async () => {
      const loginDto: LoginDto = {
        username: 'agent.ilafy.01',
        password: '123456',
      };
      const result = { access_token: 'token' };
      authService.login.mockResolvedValue(result);

      await expect(controller.login(loginDto)).resolves.toBe(result);
      expect(authService.login).toHaveBeenCalledWith(loginDto);
    });
  });

  describe('getProfile', () => {
    it('should pass the user id from the JWT payload to AuthService', async () => {
      const user: JwtPayload = {
        sub: 'agent-1',
        username: 'agent.ilafy.01',
        roleId: 'role-1',
        centreId: 'centre-1',
      };
      const result = { id: 'agent-1' };
      authService.getProfile.mockResolvedValue(result);

      await expect(controller.getProfile(user)).resolves.toBe(result);
      expect(authService.getProfile).toHaveBeenCalledWith(user.sub);
    });
  });
});
