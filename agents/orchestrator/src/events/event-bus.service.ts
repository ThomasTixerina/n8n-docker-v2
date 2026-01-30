import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis, { RedisOptions } from 'ioredis';
import { EventType, EventPayload } from './event-types.enum';

@Injectable()
export class EventBusService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(EventBusService.name);
  private publisher: Redis;
  private subscriber: Redis;
  private readonly handlers: Map<EventType, ((payload: EventPayload) => void)[]> = new Map();
  private isConnected = false;

  constructor(private readonly configService: ConfigService) {}

  async onModuleInit() {
    await this.connect();
  }

  async onModuleDestroy() {
    await this.disconnect();
  }

  private async connect(): Promise<void> {
    const redisUrl = this.configService.get<string>('REDIS_URL') || 'redis://localhost:6379';
    
    const redisOptions: RedisOptions = {
      maxRetriesPerRequest: 3,
      retryStrategy: (times: number) => {
        if (times > 10) {
          this.logger.error('Redis connection failed after 10 retries');
          return null; // Stop retrying
        }
        const delay = Math.min(times * 500, 5000);
        this.logger.warn(`Redis retry attempt ${times}, waiting ${delay}ms...`);
        return delay;
      },
      lazyConnect: true,
      enableReadyCheck: true,
      connectTimeout: 10000,
    };

    try {
      this.publisher = new Redis(redisUrl, redisOptions);
      this.subscriber = new Redis(redisUrl, redisOptions);

      await this.publisher.connect();
      await this.subscriber.connect();

      this.subscriber.on('message', (channel: string, message: string) => {
        this.handleMessage(channel, message);
      });

      this.isConnected = true;
      this.logger.log(`Connected to Redis at ${redisUrl}`);
      
      // Emit startup event
      await this.emit({
        type: EventType.SYSTEM_STARTUP,
        timestamp: new Date(),
        data: { service: 'orchestrator' },
      });
    } catch (error) {
      this.logger.error(`Failed to connect to Redis: ${error.message}`);
      this.isConnected = false;
      // Don't throw - allow app to start without Redis for graceful degradation
    }
  }

  private async disconnect(): Promise<void> {
    if (this.publisher) {
      await this.publisher.quit();
    }
    if (this.subscriber) {
      await this.subscriber.quit();
    }
    this.isConnected = false;
    this.logger.log('Disconnected from Redis');
  }

  async emit(payload: EventPayload): Promise<void> {
    if (!this.isConnected) {
      this.logger.warn(`Event ${payload.type} not emitted - Redis not connected`);
      return;
    }

    try {
      const message = JSON.stringify(payload);
      await this.publisher.publish('miconsul:events', message);
      this.logger.debug(`Event emitted: ${payload.type}`);
    } catch (error) {
      this.logger.error(`Failed to emit event ${payload.type}: ${error.message}`);
    }
  }

  subscribe(eventType: EventType, handler: (payload: EventPayload) => void): void {
    if (!this.handlers.has(eventType)) {
      this.handlers.set(eventType, []);
    }
    this.handlers.get(eventType)!.push(handler);

    if (this.isConnected) {
      this.subscriber.subscribe('miconsul:events');
    }
  }

  private handleMessage(channel: string, message: string): void {
    try {
      const payload: EventPayload = JSON.parse(message);
      const handlers = this.handlers.get(payload.type) || [];
      handlers.forEach(handler => handler(payload));
    } catch (error) {
      this.logger.error(`Failed to handle message: ${error.message}`);
    }
  }

  getConnectionStatus(): boolean {
    return this.isConnected;
  }
}
