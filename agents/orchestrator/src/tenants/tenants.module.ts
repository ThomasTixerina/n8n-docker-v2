import { Module } from '@nestjs/common';
import { TenantManagerService } from './tenant-manager.service';
import { TenantsController } from './tenants.controller';

@Module({
  controllers: [TenantsController],
  providers: [TenantManagerService],
  exports: [TenantManagerService],
})
export class TenantsModule {}
