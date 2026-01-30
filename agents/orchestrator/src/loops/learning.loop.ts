import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { EventBusService } from '../events/event-bus.service';
import { EventType } from '../events/event-types.enum';

@Injectable()
export class LearningLoop {
  private readonly logger = new Logger(LearningLoop.name);

  constructor(private readonly eventBus: EventBusService) {}

  @Cron(CronExpression.EVERY_HOUR)
  async handleLearningTick() {
    this.logger.log('Learning loop tick');

    await this.eventBus.emit({
      type: EventType.LEARNING_TICK,
      timestamp: new Date(),
    });

    // TODO: Learn from all tenants' execution patterns
    // Update best practices and workflow templates
  }
}
