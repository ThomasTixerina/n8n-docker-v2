import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Octokit } from '@octokit/rest';
import * as sodium from 'libsodium-wrappers';

@Injectable()
export class GithubManagerService implements OnModuleInit {
  private readonly logger = new Logger(GithubManagerService.name);
  private octokit: Octokit | null = null;
  private readonly org: string;

  constructor(private readonly configService: ConfigService) {
    this.org = this.configService.get<string>('GITHUB_ORG') || 'miconsul-workflows';
  }

  async onModuleInit() {
    const token = this.configService.get<string>('GITHUB_TOKEN');
    
    if (!token) {
      this.logger.warn('GITHUB_TOKEN not configured - GitHub features disabled');
      return;
    }

    this.octokit = new Octokit({ auth: token });
    this.logger.log(`GitHub Manager initialized for org: ${this.org}`);
  }

  private ensureOctokit(): Octokit {
    if (!this.octokit) {
      throw new Error('GitHub not configured. Set GITHUB_TOKEN in environment.');
    }
    return this.octokit;
  }

  async createTenantRepository(tenantId: string, isPrivate = true): Promise<string> {
    const octokit = this.ensureOctokit();
    const repoName = `tenant-${tenantId}-workflows`;

    try {
      const { data } = await octokit.repos.createInOrg({
        org: this.org,
        name: repoName,
        private: isPrivate,
        description: `n8n workflows for tenant ${tenantId}`,
        auto_init: true,
      });

      this.logger.log(`Created repository: ${data.html_url}`);
      return data.html_url;
    } catch (error) {
      if (error.status === 422) {
        this.logger.warn(`Repository ${repoName} already exists`);
        return `https://github.com/${this.org}/${repoName}`;
      }
      throw error;
    }
  }

  async setupWebhook(tenantId: string, webhookUrl: string): Promise<void> {
    const octokit = this.ensureOctokit();
    const repoName = `tenant-${tenantId}-workflows`;

    await octokit.repos.createWebhook({
      owner: this.org,
      repo: repoName,
      config: {
        url: webhookUrl,
        content_type: 'json',
      },
      events: ['push', 'pull_request'],
    });

    this.logger.log(`Webhook configured for ${repoName}`);
  }

  async addRepositorySecret(
    tenantId: string, 
    secretName: string, 
    secretValue: string
  ): Promise<void> {
    const octokit = this.ensureOctokit();
    const repoName = `tenant-${tenantId}-workflows`;

    // Get repository public key for encryption
    const { data: publicKey } = await octokit.actions.getRepoPublicKey({
      owner: this.org,
      repo: repoName,
    });

    // Encrypt the secret using libsodium
    await sodium.ready;
    const binKey = sodium.from_base64(publicKey.key, sodium.base64_variants.ORIGINAL);
    const binSecret = sodium.from_string(secretValue);
    const encryptedBytes = sodium.crypto_box_seal(binSecret, binKey);
    const encryptedValue = sodium.to_base64(encryptedBytes, sodium.base64_variants.ORIGINAL);

    await octokit.actions.createOrUpdateRepoSecret({
      owner: this.org,
      repo: repoName,
      secret_name: secretName,
      encrypted_value: encryptedValue,
      key_id: publicKey.key_id,
    });

    this.logger.log(`Secret ${secretName} added to ${repoName}`);
  }

  async listTenantWorkflows(tenantId: string): Promise<string[]> {
    const octokit = this.ensureOctokit();
    const repoName = `tenant-${tenantId}-workflows`;

    try {
      const { data } = await octokit.repos.getContent({
        owner: this.org,
        repo: repoName,
        path: 'workflows',
      });

      if (Array.isArray(data)) {
        return data
          .filter(item => item.type === 'file' && item.name.endsWith('.json'))
          .map(item => item.name);
      }
      return [];
    } catch (error) {
      if (error.status === 404) {
        return [];
      }
      throw error;
    }
  }

  isConfigured(): boolean {
    return this.octokit !== null;
  }
}
