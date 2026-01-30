export interface TenantConfig {
  id: string;
  name: string;
  plan: 'basic' | 'pro' | 'enterprise';
  port: number;
  status: 'active' | 'suspended' | 'pending';
  createdAt: Date;
  updatedAt: Date;
  settings: TenantSettings;
  limits: TenantLimits;
  health?: TenantHealth;
}

export interface TenantSettings {
  n8nUrl: string;
  webhookUrl?: string;
  cloudflareEnabled: boolean;
  githubRepo?: string;
  customDomain?: string;
}

export interface TenantLimits {
  maxWorkflows: number;
  maxExecutionsPerMonth: number;
  currentExecutions: number;
}

export interface TenantHealth {
  status: 'healthy' | 'degraded' | 'unhealthy';
  lastCheck: Date;
  uptime: number;
  errors: string[];
}
