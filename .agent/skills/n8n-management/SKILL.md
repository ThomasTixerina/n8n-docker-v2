---
name: n8n-management
description: Skill for managing n8n workflows, validating JSON, and performing health checks
---

# n8n Management Skill

This skill provides utilities for managing n8n workflows in a production environment with Cloudflare Tunnel integration.

## Overview

This skill encapsulates common n8n operations that AI agents should use when helping users with workflow management, validation, and troubleshooting.

---

## Capabilities

### 1. Validate Workflow JSON

**When to use**: Before saving any workflow file, or when user reports JSON errors.

**Instructions**:
```powershell
# Validate a single workflow file
Get-Content "workflow-name.json" | ConvertFrom-Json | Out-Null

# Validate all workflows in directory
Get-ChildItem -Filter "*.json" -File | Where-Object { $_.Name -notmatch "package" } | ForEach-Object {
    Write-Host "Validating $($_.Name)..."
    try {
        Get-Content $_.FullName | ConvertFrom-Json | Out-Null
        Write-Host "✅ $($_.Name) is valid" -ForegroundColor Green
    } catch {
        Write-Host "❌ $($_.Name) has errors: $_" -ForegroundColor Red
    }
}
```

**Expected Output**: Confirmation of valid JSON or specific syntax errors.

---

### 2. Check n8n Health

**When to use**: User asks "is n8n working?", "está corriendo?", or before making changes.

**Instructions**:
```powershell
# Quick health check
.\monitor-n8n.ps1
```

**What it checks**:
- Docker container status (n8n-v2, n8n-tunnel)
- Cloudflare Tunnel connectivity
- n8n HTTP health endpoint
- Recent workflow executions
- Resource usage (CPU, memory)

**Expected Output**: Dashboard showing system health metrics.

---

### 3. Get Current n8n URL

**When to use**: Before suggesting user to open n8n editor, or when webhooks aren't working.

**Instructions**:
```powershell
# Get the current Cloudflare Tunnel URL
docker logs n8n-tunnel 2>&1 | Select-String "https://" | Select-Object -Last 1

# Or read from .env file
Get-Content .env | Select-String "N8N_EDITOR_BASE_URL"
```

**Expected Output**: The current HTTPS URL for accessing n8n.

---

### 4. Backup Workflows

**When to use**: Before modifying workflows, migrating, or updating configurations.

**Instructions**:
```powershell
# Create timestamped backup (built into start-n8n.ps1)
.\start-n8n.ps1  # This creates backup automatically

# Or manual backup
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupDir = "backups\workflows_$timestamp"
New-Item -ItemType Directory -Path $backupDir -Force
Copy-Item "*.json" -Destination $backupDir -Exclude "package*.json"
Write-Host "✅ Backup created: $backupDir"
```

**Expected Output**: Confirmation of backup location.

---

### 5. Publish Workflow to Git

**When to use**: After successfully testing a new or modified workflow.

**Instructions**:
```powershell
# Add workflow to git
git add workflow-name.json

# Commit with descriptive message
git commit -m "feat: Add/Update workflow-name - Brief description of changes"

# Push to remote
git push origin main
```

**Best Practices**:
- Use conventional commit format: `feat:`, `fix:`, `chore:`
- Include brief description of what the workflow does
- Ensure workflow has been tested before committing

---

### 6. Test Webhook

**When to use**: After creating/modifying a webhook-triggered workflow.

**Instructions**:
```powershell
# Get webhook URL from .env
$webhookUrl = (Get-Content .env | Select-String "WEBHOOK_URL").ToString().Split('=')[1]

# Test webhook with sample data
$testData = @{
    event = "test"
    timestamp = Get-Date -Format "o"
    message = "Test from n8n-management skill"
} | ConvertTo-Json

Invoke-WebRequest -Uri "$webhookUrl/webhook/test" -Method POST -Body $testData -ContentType "application/json"
```

**Expected Output**: HTTP 200 response or workflow execution confirmation.

---

### 7. View Recent Logs

**When to use**: Debugging workflow failures, checking for errors.

**Instructions**:
```powershell
# View last 50 lines of n8n logs
docker logs n8n-v2 --tail 50

# Follow logs in real-time
docker logs n8n-v2 -f

# Filter for errors only
docker logs n8n-v2 --tail 100 | Select-String "error|ERROR|fail|FAIL"
```

**Expected Output**: Log entries showing n8n activity and potential errors.

---

### 8. Restart n8n (Safe)

**When to use**: When n8n is unresponsive, after configuration changes, or if auto-healing hasn't worked.

**Instructions**:
```powershell
# Check if any workflows are currently executing
docker logs n8n-v2 --tail 20 | Select-String "Execution.*started"

# If safe to restart:
docker-compose restart n8n

# Wait for n8n to be ready
Start-Sleep -Seconds 10

# Verify it's running
.\monitor-n8n.ps1
```

**Expected Output**: Confirmation that n8n restarted successfully.

---

## Environment Variable Reference

Key variables in `.env` that this skill references:

- `N8N_EDITOR_BASE_URL` - Main n8n editor URL
- `WEBHOOK_URL` - Dynamic Cloudflare Tunnel URL for webhooks
- `N8N_MCP_TOKEN` - Token for MCP authentication
- `GITHUB_TOKEN` - For Git operations

**Always read these from `.env` - NEVER hardcode.**

---

## Common Workflows

### Creating a New Workflow
1. Design in n8n UI (use `N8N_EDITOR_BASE_URL`)
2. Test execution thoroughly
3. Export as JSON from n8n
4. Save to project root
5. Validate JSON syntax
6. Backup existing workflows
7. Commit to Git

### Troubleshooting Failed Workflow
1. Run `.\monitor-n8n.ps1` for overview
2. Check Docker logs for errors
3. Verify webhook URL is current
4. Test webhook manually
5. Check if autonomous agents already detected issue
6. Review workflow execution in n8n UI

### Updating Webhook URL
1. Get new URL from Cloudflare Tunnel logs
2. Update `.env` → `WEBHOOK_URL`
3. Update `docker-compose.yml` if needed
4. Restart affected workflows
5. Test webhooks

---

## Integration with Autonomous Agents

This skill is for **manual operations**. For routine monitoring and auto-healing:
- Let the **Monitoring Loop** (30s) detect issues
- Let the **Support Agent** handle auto-healing
- Check `agents/orchestrator/` for autonomous agent status

**Use this skill when**:
- Autonomous agents haven't resolved issue
- Manual workflow creation/modification needed
- User explicitly requests manual operation

---

## Examples

### Scenario: User wants to create welcome email workflow
```powershell
# 1. Check n8n is running
.\monitor-n8n.ps1

# 2. Get URL to open editor
$url = (Get-Content .env | Select-String "N8N_EDITOR_BASE_URL").ToString().Split('=')[1]
Write-Host "Open n8n editor: $url"

# 3. After user creates workflow in UI and exports it:
# 4. Validate the exported file
Get-Content "welcome_email.json" | ConvertFrom-Json | Out-Null

# 5. Backup and commit
.\start-n8n.ps1  # Auto-backups
git add welcome_email.json
git commit -m "feat: Add welcome email workflow for new patients"
git push
```

### Scenario: Webhooks stopped working
```powershell
# 1. Check current webhook URL
$currentUrl = (Get-Content .env | Select-String "WEBHOOK_URL").ToString().Split('=')[1]
Write-Host "Current webhook URL: $currentUrl"

# 2. Get new URL from tunnel
docker logs n8n-tunnel 2>&1 | Select-String "https://" | Select-Object -Last 1

# 3. If URL changed, update .env (manual edit)
# 4. Restart n8n
docker-compose restart n8n

# 5. Test webhook
Invoke-WebRequest -Uri "$currentUrl/webhook/test" -Method POST
```

---

**Last Updated**: 2026-01-16
**Version**: 1.0
**Compatibility**: n8n with Docker + Cloudflare Tunnel
