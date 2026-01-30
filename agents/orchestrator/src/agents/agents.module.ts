import { Module } from '@nestjs/common';
import { TenantsModule } from '../tenants/tenants.module';
import { DeploymentAgent } from './deployment.agent';
import { SupportAgent } from './support.agent';
import { CustomizationAgent } from './customization.agent';
import { MigrationAgent } from './migration.agent';

@Module({
  imports: [TenantsModule],
  providers: [
    DeploymentAgent,
    SupportAgent,
    CustomizationAgent,
    MigrationAgent,
  ],
  exports: [DeploymentAgent, SupportAgent, CustomizationAgent, MigrationAgent],
})
export class AgentsModule {}
