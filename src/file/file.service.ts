import { BadRequestException, Injectable } from '@nestjs/common';
import { existsSync, mkdirSync } from 'fs';
import { join, extname } from 'path';
import { randomUUID } from 'crypto';

@Injectable()
export class FileService {
  private readonly uploadDirectory = join(process.cwd(), 'uploads');

  constructor() {
    this.ensureUploadDirectory();
  }

  private ensureUploadDirectory() {
    if (!existsSync(this.uploadDirectory)) {
      mkdirSync(this.uploadDirectory, {
        recursive: true,
      });
    }
  }

  async saveFile(file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('File is required');
    }

    const extension = extname(file.originalname);

    const filename = `${randomUUID()}${extension}`;

    const filepath = join(this.uploadDirectory, filename);

    const fs = await import('fs/promises');

    await fs.writeFile(filepath, file.buffer);

    return {
      filename,
      path: `/uploads/${filename}`,
    };
  }
}
