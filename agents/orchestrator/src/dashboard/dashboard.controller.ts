import { Controller, Get, Logger } from '@nestjs/common';
import { TenantManagerService } from '../tenants/tenant-manager.service';
import { EventBusService } from '../events/event-bus.service';

@Controller('dashboard')
export class DashboardController {
  private readonly logger = new Logger(DashboardController.name);
  private readonly startTime = Date.now();

  constructor(
    private readonly tenantManager: TenantManagerService,
    private readonly eventBus: EventBusService,
  ) {}

  @Get('status')
  getStatus() {
    const tenants = this.tenantManager.getAllTenants();
    const activeTenants = tenants.filter(t => t.status === 'active');
    const suspendedTenants = tenants.filter(t => t.status === 'suspended');

    return {
      status: this.eventBus.getConnectionStatus() ? 'healthy' : 'degraded',
      uptime: (Date.now() - this.startTime) / 1000,
      timestamp: new Date().toISOString(),
      redis: this.eventBus.getConnectionStatus() ? 'connected' : 'disconnected',
      tenants: {
        total: tenants.length,
        active: activeTenants.length,
        suspended: suspendedTenants.length,
      },
      loops: {
        monitoring: 'running',
        optimization: 'running',
        predictive: 'running',
        learning: 'running',
        maintenance: 'running',
      },
    };
  }

  @Get('tenants')
  getTenants() {
    return this.tenantManager.getAllTenants().map(tenant => ({
      id: tenant.id,
      name: tenant.name,
      plan: tenant.plan,
      status: tenant.status,
      port: tenant.port,
      health: tenant.health,
      settings: tenant.settings,
    }));
  }

  @Get('health')
  async getHealthReport() {
    const healthResults = await this.tenantManager.checkAllTenantsHealth();
    const summary = {
      timestamp: new Date().toISOString(),
      totalChecked: healthResults.size,
      healthy: 0,
      degraded: 0,
      unhealthy: 0,
      details: {} as Record<string, unknown>,
    };

    healthResults.forEach((health, tenantId) => {
      summary.details[tenantId] = health;
      if (health.status === 'healthy') summary.healthy++;
      else if (health.status === 'degraded') summary.degraded++;
      else summary.unhealthy++;
    });

    return summary;
  }
}
