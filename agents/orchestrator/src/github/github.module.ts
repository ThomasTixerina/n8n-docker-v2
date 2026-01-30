import { Module } from '@nestjs/common';
import { GithubManagerService } from './github-manager.service';

@Module({
  providers: [GithubManagerService],
  exports: [GithubManagerService],
})
export class GithubModule {}
