import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';

import { EventsModule } from './events/events.module';
import { TenantsModule } from './tenants/tenants.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { LoopsModule } from './loops/loops.module';
import { AgentsModule } from './agents/agents.module';
import { GithubModule } from './github/github.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ScheduleModule.forRoot(),
    EventsModule,
    TenantsModule,
    DashboardModule,
    LoopsModule,
    AgentsModule,
    GithubModule,
  ],
})
export class AppModule {}
