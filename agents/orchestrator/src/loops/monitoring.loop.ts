import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { TenantManagerService } from '../tenants/tenant-manager.service';
import { EventBusService } from '../events/event-bus.service';
import { EventType } from '../events/event-types.enum';

@Injectable()
export class MonitoringLoop {
  private readonly logger = new Logger(MonitoringLoop.name);

  constructor(
    private readonly tenantManager: TenantManagerService,
    private readonly eventBus: EventBusService,
  ) {}

  @Cron(CronExpression.EVERY_30_SECONDS)
  async handleMonitoringTick() {
    this.logger.debug('Monitoring loop tick');

    await this.eventBus.emit({
      type: EventType.MONITORING_TICK,
      timestamp: new Date(),
    });

    const activeTenants = this.tenantManager.getActiveTenants();
    
    for (const tenant of activeTenants) {
      try {
        const health = await this.tenantManager.checkTenantHealth(tenant.id);
        
        if (health.status !== 'healthy') {
          this.logger.warn(`Tenant ${tenant.id} health: ${health.status}`);
        }
      } catch (error) {
        this.logger.error(`Failed to check health for ${tenant.id}: ${error.message}`);
      }
    }
  }
}
