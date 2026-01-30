# MiConsul Orchestrator - Quick Start Guide

## 🚀 Setup & Installation

### 1. Install Dependencies

```powershell
cd agents\orchestrator
npm install
```

### 2. Configure Environment

```powershell
# Copy example env
Copy-Item .env.example .env

# Edit .env with your values
notepad .env
```

**Required variables:**
- `REDIS_HOST` - Redis server (default: localhost)
- `POSTGRES_HOST` - PostgreSQL server (default: localhost)
- `GITHUB_TOKEN` - GitHub personal access token

### 3. Start Required Services

You need Redis and PostgreSQL running. You can use Docker:

```powershell
# Create docker-compose.yml for orchestrator services
```

Or install locally.

### 4. Run the Orchestrator

**Development mode (with hot-reload):**
```powershell
npm run dev
```

**Production mode:**
```powershell
npm run build
npm start
```

The orchestrator will start on `http://localhost:3000`

---

## 📊 API Endpoints

### System Status
```
GET http://localhost:3000/api/dashboard/status
```

Returns:
```json
{
  "status": "healthy",
  "uptime": 123.45,
  "timestamp": "2025-12-25T09:00:00Z",
  "tenants": {
    "total": 3,
    "active": 3,
    "suspended": 0
  },
  "loops": {
    "monitoring": "running",
    "optimization": "pending",
    "predictive": "pending",
    "learning": "pending",
    "maintenance": "pending"
  }
}
```

### List All Tenants
```
GET http://localhost:3000/api/dashboard/tenants
```

### Get Specific Tenant
```
GET http://localhost:3000/api/dashboard/tenants/cdental
```

---

## 🔄 How It Works

### 1. Tenant Loading
On startup, the orchestrator scans the `clients/` directory and loads all tenant configurations.

### 2. Monitoring Loop
Every 30 seconds, the monitoring loop:
- Checks health of each active tenant
- Verifies n8n is responding
- Emits events if issues are detected

### 3. Event Bus
All components communicate via Redis pub/sub:
- Loops emit events when they detect issues
- Agents listen for events and respond
- Everything is asynchronous and decoupled

---

## 🧪 Testing

```powershell
# Run tests
npm test

# With coverage
npm run test:cov

# Watch mode
npm run test:watch
```

---

## 📝 Logs

The orchestrator logs to console. You'll see:
- `[EventBusService]` - Event bus activity
- `[TenantManagerService]` - Tenant loading/management
- `[MonitoringLoop]` - Health checks
- `[DashboardController]` - API requests

---

## 🔧 Troubleshooting

### Orchestrator won't start

**Check Redis connection:**
```powershell
# Test Redis
docker ps | Select-String "redis"

# Or if local
redis-cli ping
```

**Check PostgreSQL:**
```powershell
docker ps | Select-String "postgres"
```

### No tenants loaded

The orchestrator looks for tenants in `../../clients/` relative to the orchestrator directory.

Make sure you've created at least one client:
```powershell
cd ..\..
.\scripts\create_client_instance.ps1 -TenantId "test" -TenantName "Test" -Plan "basic" -Port 5678
```

### Health checks failing

Verify the tenant's n8n is running:
```powershell
docker ps | Select-String "n8n-"
curl http://localhost:5678/healthz
```

---

## 🎯 Next Steps

1. **Create test tenant** - Use provisioning script
2. **Monitor logs** - Watch the monitoring loop in action
3. **Test API** - Hit the dashboard endpoints
4. **Add more loops** - Implement Optimization, Predictive, etc.

---

**Full Documentation**: See `/docs` directory
