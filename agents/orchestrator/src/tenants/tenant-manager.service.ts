import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs';
import * as path from 'path';
import axios from 'axios';
import { TenantConfig, TenantHealth } from './tenant.interface';
import { EventBusService } from '../events/event-bus.service';
import { EventType } from '../events/event-types.enum';

@Injectable()
export class TenantManagerService implements OnModuleInit {
  private readonly logger = new Logger(TenantManagerService.name);
  private tenants: Map<string, TenantConfig> = new Map();
  private readonly clientsDir: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly eventBus: EventBusService,
  ) {
    this.clientsDir = this.configService.get<string>('CLIENTS_DIR') || 
      path.resolve(__dirname, '../../../../clients');
  }

  async onModuleInit() {
    await this.loadTenants();
  }

  private async loadTenants(): Promise<void> {
    this.logger.log(`Loading tenants from ${this.clientsDir}`);

    if (!fs.existsSync(this.clientsDir)) {
      this.logger.warn(`Clients directory not found: ${this.clientsDir}`);
      return;
    }

    const entries = fs.readdirSync(this.clientsDir, { withFileTypes: true });

    for (const entry of entries) {
      if (entry.isDirectory()) {
        await this.loadTenant(entry.name);
      }
    }

    this.logger.log(`Loaded ${this.tenants.size} tenants`);
  }

  private async loadTenant(tenantId: string): Promise<void> {
    const tenantPath = path.join(this.clientsDir, tenantId);
    const configPath = path.join(tenantPath, 'config.json');
    const envPath = path.join(tenantPath, '.env');

    if (!fs.existsSync(configPath)) {
      this.logger.warn(`No config.json found for tenant ${tenantId}`);
      return;
    }

    try {
      const configContent = fs.readFileSync(configPath, 'utf-8');
      const config = JSON.parse(configContent);

      const tenant: TenantConfig = {
        id: tenantId,
        name: config.name || tenantId,
        plan: config.plan || 'basic',
        port: config.port || 5678,
        status: config.status || 'active',
        createdAt: new Date(config.createdAt || Date.now()),
        updatedAt: new Date(config.updatedAt || Date.now()),
        settings: {
          n8nUrl: config.n8nUrl || `http://localhost:${config.port || 5678}`,
          webhookUrl: config.webhookUrl,
          cloudflareEnabled: config.cloudflareEnabled !== false,
          githubRepo: config.githubRepo,
          customDomain: config.customDomain,
        },
        limits: {
          maxWorkflows: this.getPlanLimits(config.plan).workflows,
          maxExecutionsPerMonth: this.getPlanLimits(config.plan).executions,
          currentExecutions: 0,
        },
      };

      this.tenants.set(tenantId, tenant);
      this.logger.log(`Loaded tenant: ${tenantId} (${tenant.plan})`);
    } catch (error) {
      this.logger.error(`Failed to load tenant ${tenantId}: ${error.message}`);
    }
  }

  private getPlanLimits(plan: string): { workflows: number; executions: number } {
    switch (plan) {
      case 'enterprise':
        return { workflows: Infinity, executions: Infinity };
      case 'pro':
        return { workflows: 15, executions: 5000 };
      default:
        return { workflows: 5, executions: 1000 };
    }
  }

  getAllTenants(): TenantConfig[] {
    return Array.from(this.tenants.values());
  }

  getTenant(id: string): TenantConfig | undefined {
    return this.tenants.get(id);
  }

  getActiveTenants(): TenantConfig[] {
    return this.getAllTenants().filter(t => t.status === 'active');
  }

  async checkTenantHealth(tenantId: string): Promise<TenantHealth> {
    const tenant = this.tenants.get(tenantId);
    if (!tenant) {
      throw new Error(`Tenant not found: ${tenantId}`);
    }

    const health: TenantHealth = {
      status: 'unhealthy',
      lastCheck: new Date(),
      uptime: 0,
      errors: [],
    };

    try {
      const response = await axios.get(`${tenant.settings.n8nUrl}/healthz`, {
        timeout: 5000,
      });

      if (response.status === 200) {
        health.status = 'healthy';
      } else {
        health.status = 'degraded';
        health.errors.push(`Unexpected status: ${response.status}`);
      }
    } catch (error) {
      health.status = 'unhealthy';
      health.errors.push(error.message);
    }

    tenant.health = health;
    this.tenants.set(tenantId, tenant);

    // Emit health event
    await this.eventBus.emit({
      type: health.status === 'healthy' 
        ? EventType.TENANT_HEALTH_CHECK 
        : EventType.TENANT_HEALTH_DEGRADED,
      tenantId,
      timestamp: new Date(),
      data: { health },
    });

    return health;
  }

  async checkAllTenantsHealth(): Promise<Map<string, TenantHealth>> {
    const results = new Map<string, TenantHealth>();

    for (const tenant of this.getActiveTenants()) {
      try {
        const health = await this.checkTenantHealth(tenant.id);
        results.set(tenant.id, health);
      } catch (error) {
        this.logger.error(`Health check failed for ${tenant.id}: ${error.message}`);
      }
    }

    return results;
  }

  async refreshTenants(): Promise<void> {
    this.tenants.clear();
    await this.loadTenants();
  }
}
