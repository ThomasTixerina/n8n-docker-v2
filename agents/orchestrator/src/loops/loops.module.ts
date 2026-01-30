import { Module } from '@nestjs/common';
import { TenantsModule } from '../tenants/tenants.module';
import { MonitoringLoop } from './monitoring.loop';
import { OptimizationLoop } from './optimization.loop';
import { PredictiveLoop } from './predictive.loop';
import { LearningLoop } from './learning.loop';
import { MaintenanceLoop } from './maintenance.loop';

@Module({
  imports: [TenantsModule],
  providers: [
    MonitoringLoop,
    OptimizationLoop,
    PredictiveLoop,
    LearningLoop,
    MaintenanceLoop,
  ],
})
export class LoopsModule {}
