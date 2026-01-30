$ErrorActionPreference = "Stop"

$SERVER_IP = "100.101.161.29"
$SSH_USER = "ttijerina"
$REMOTE_DEST = "/tmp/miconsul_modernization.tar.gz"
$LOCAL_ARCHIVE = "$PWD\miconsul_modernization.tar.gz"
$CODE_DIR = "$PWD\miconsul_codebase"

Write-Host "📦 Creating Tarball from $CODE_DIR..."
# Windows tar (bsdtar) supports -C
tar -czf "miconsul_modernization.tar.gz" -C "miconsul_codebase" .

if (-not (Test-Path $LOCAL_ARCHIVE)) {
    Write-Error "Archive not created: $LOCAL_ARCHIVE"
    exit 1
}

Write-Host "🚀 Target: $SSH_USER@$SERVER_IP"
Write-Host "ℹ️  Password: C+dental25" -ForegroundColor Yellow

# SCP
$scpArgs = @(
    "-o", "StrictHostKeyChecking=no",
    "$LOCAL_ARCHIVE",
    "$SSH_USER@$SERVER_IP`:$REMOTE_DEST"
)
Write-Host "Running: scp $scpArgs"
& scp $scpArgs

# SSH
# Ensure directory exists, extract, set ownership/permissions, cleanup
$cmd = "mkdir -p /var/www/miconsul && tar -xzf /tmp/miconsul_modernization.tar.gz -C /var/www/miconsul && sudo chown -R www-data:www-data /var/www/miconsul/app/Core /var/www/miconsul/api && sudo chmod +x /var/www/miconsul/api/n8n.php && rm /tmp/miconsul_modernization.tar.gz"
$sshArgs = @(
    "-o", "StrictHostKeyChecking=no",
    "$SSH_USER@$SERVER_IP",
    $cmd
)
Write-Host "Running: ssh ..."
& ssh $sshArgs

Write-Host "✅ Done!" -ForegroundColor Green
