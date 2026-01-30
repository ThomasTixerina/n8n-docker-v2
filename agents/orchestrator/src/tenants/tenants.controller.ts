import { Controller, Get, Param, Post, HttpException, HttpStatus } from '@nestjs/common';
import { TenantManagerService } from './tenant-manager.service';
import { TenantConfig } from './tenant.interface';

@Controller('tenants')
export class TenantsController {
  constructor(private readonly tenantManager: TenantManagerService) {}

  @Get()
  getAllTenants(): TenantConfig[] {
    return this.tenantManager.getAllTenants();
  }

  @Get('active')
  getActiveTenants(): TenantConfig[] {
    return this.tenantManager.getActiveTenants();
  }

  @Get(':id')
  getTenant(@Param('id') id: string): TenantConfig {
    const tenant = this.tenantManager.getTenant(id);
    if (!tenant) {
      throw new HttpException('Tenant not found', HttpStatus.NOT_FOUND);
    }
    return tenant;
  }

  @Get(':id/health')
  async getTenantHealth(@Param('id') id: string) {
    try {
      return await this.tenantManager.checkTenantHealth(id);
    } catch (error) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  @Post('refresh')
  async refreshTenants() {
    await this.tenantManager.refreshTenants();
    return { message: 'Tenants refreshed', count: this.tenantManager.getAllTenants().length };
  }
}
