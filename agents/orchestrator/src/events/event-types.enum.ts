export enum EventType {
  // Tenant Events
  TENANT_CREATED = 'tenant.created',
  TENANT_UPDATED = 'tenant.updated',
  TENANT_DELETED = 'tenant.deleted',
  TENANT_HEALTH_CHECK = 'tenant.health_check',
  TENANT_HEALTH_DEGRADED = 'tenant.health_degraded',
  TENANT_RECOVERED = 'tenant.recovered',

  // Workflow Events
  WORKFLOW_CREATED = 'workflow.created',
  WORKFLOW_UPDATED = 'workflow.updated',
  WORKFLOW_DELETED = 'workflow.deleted',
  WORKFLOW_EXECUTED = 'workflow.executed',
  WORKFLOW_FAILED = 'workflow.failed',
  WORKFLOW_OPTIMIZED = 'workflow.optimized',

  // System Events
  SYSTEM_STARTUP = 'system.startup',
  SYSTEM_SHUTDOWN = 'system.shutdown',
  SYSTEM_ERROR = 'system.error',

  // Loop Events
  MONITORING_TICK = 'loop.monitoring.tick',
  OPTIMIZATION_TICK = 'loop.optimization.tick',
  PREDICTIVE_TICK = 'loop.predictive.tick',
  LEARNING_TICK = 'loop.learning.tick',
  MAINTENANCE_TICK = 'loop.maintenance.tick',

  // Agent Events
  AGENT_DEPLOYMENT_REQUEST = 'agent.deployment.request',
  AGENT_SUPPORT_REQUEST = 'agent.support.request',
  AGENT_CUSTOMIZATION_REQUEST = 'agent.customization.request',
  AGENT_MIGRATION_REQUEST = 'agent.migration.request',
}

export interface EventPayload {
  type: EventType;
  tenantId?: string;
  timestamp: Date;
  data?: Record<string, unknown>;
}
