---
name: Managing n8n MCP Server
description: Manages the n8n MCP Server integration for AI assistant workflow automation via Model Context Protocol
version: "1.0"
updated: 2026-02-19
tags:
  - n8n
  - mcp
  - automation
  - ai-assistant
globs:
  - docker-compose.yml
  - .agent/mcp-config.yaml
  - test_mcp.js
---

# Managing n8n MCP Server

This skill provides guidance for using the **leonardsellem/n8n-mcp-server** (v0.1.8) — a Model Context Protocol server that enables AI assistants to interact with n8n workflows through natural language.

## Overview

The n8n MCP Server runs as a Docker sidecar alongside n8n and exposes workflow management capabilities via the MCP protocol. It allows AI assistants (Claude, Cursor, etc.) to programmatically manage workflows and executions.

**Repository**: https://github.com/leonardsellem/n8n-mcp-server
**Docker image**: `leonardsellem/n8n-mcp-server:latest`
**npm package**: `@leonardsellem/n8n-mcp-server` v0.1.8

## Prerequisites

1. n8n instance running with API access enabled
2. n8n API key generated (Settings → API → API Keys)
3. Docker Compose environment configured

## Configuration

### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `N8N_API_KEY` | API key for n8n authentication | `n8n_api_...` |
| `N8N_API_URL` | Internal n8n API URL | `http://n8n:5678/api/v1` |
| `N8N_WEBHOOK_USERNAME` | Webhook basic auth username | `username` |
| `N8N_WEBHOOK_PASSWORD` | Webhook basic auth password | `password` |

### Docker Service

The MCP server runs as a service in `docker-compose.yml`:

```yaml
n8n-mcp-server:
  image: leonardsellem/n8n-mcp-server:latest
  container_name: n8n-mcp-server
  environment:
    - N8N_API_URL=http://n8n:5678/api/v1
    - N8N_API_KEY=${N8N_API_KEY}
    - N8N_WEBHOOK_USERNAME=${N8N_WEBHOOK_USERNAME}
    - N8N_WEBHOOK_PASSWORD=${N8N_WEBHOOK_PASSWORD}
  depends_on:
    - n8n
  restart: unless-stopped
  networks:
    - n8n_network
```

## Available MCP Tools

### Workflow Management
- `workflow_list` — List all workflows
- `workflow_get` — Get details of a specific workflow
- `workflow_create` — Create a new workflow
- `workflow_update` — Update an existing workflow
- `workflow_delete` — Delete a workflow
- `workflow_activate` — Activate a workflow
- `workflow_deactivate` — Deactivate a workflow

### Execution Management
- `execution_run` — Execute a workflow via the API
- `run_webhook` — Execute a workflow via webhook
- `execution_get` — Get details of an execution
- `execution_list` — List executions for a workflow
- `execution_stop` — Stop a running execution

## Available MCP Resources

- `n8n://workflows/list` — List of all workflows
- `n8n://workflow/{id}` — Details of a specific workflow
- `n8n://executions/{workflowId}` — List of executions
- `n8n://execution/{id}` — Details of a specific execution

## AI Assistant Integration

### Claude Desktop / VS Code Configuration

```json
{
  "mcpServers": {
    "n8n": {
      "command": "node",
      "args": ["/path/to/n8n-mcp-server/build/index.js"],
      "env": {
        "N8N_API_URL": "http://localhost:5678/api/v1",
        "N8N_API_KEY": "YOUR_N8N_API_KEY"
      }
    }
  }
}
```

## Common Operations

### Verify MCP Server Health

```bash
docker logs n8n-mcp-server
docker inspect n8n-mcp-server --format='{{.State.Status}}'
```

### Test MCP Connection

```bash
node test_mcp.js
```

### Restart MCP Server

```bash
docker-compose restart n8n-mcp-server
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| MCP server not connecting | Verify `N8N_API_URL` and `N8N_API_KEY` in env |
| Authentication failed | Regenerate API key in n8n Settings → API |
| Webhook calls failing | Check `N8N_WEBHOOK_USERNAME`/`PASSWORD` |
| Container not starting | Run `docker logs n8n-mcp-server` for errors |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.1.8 | 2026-02 | Latest stable release |
| 0.1.7 | 2026-01 | Previous stable |
