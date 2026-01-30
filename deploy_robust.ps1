$ErrorActionPreference = "Stop"

$SERVER_IP = "100.101.161.29"
$SSH_USER = "ttijerina"
$REMOTE_TMP = "/tmp/miconsul_modernization.tar.gz"
$REMOTE_DIR = "/var/www/miconsul"

# 1. Prepare Paths
$baseDir = Get-Location
$codeDir = Join-Path $baseDir "miconsul_codebase"
$tarFile = Join-Path $baseDir "miconsul_modernization.tar.gz"

Write-Host "📂 Base Dir: $baseDir"
Write-Host "📂 Code Dir: $codeDir"

if (-not (Test-Path $codeDir)) {
    Write-Error "❌ Code directory not found!"
    exit 1
}

# 2. Create Tarball
Write-Host "📦 Creating Tarball..." -ForegroundColor Cyan
if (Test-Path $tarFile) { Remove-Item $tarFile }

# Using tar.exe (Windows 10/11 built-in)
# -C changes to directory so archive doesn't include 'miconsul_codebase' prefix
tar -czf "$tarFile" -C "$codeDir" .

if (-not (Test-Path $tarFile)) {
    Write-Error "❌ Archive creation failed!"
    exit 1
}
Write-Host "✅ Archive created at: $tarFile"

# 3. SCP (File Upload)
Write-Host "🚀 Uploading to $SERVER_IP..." -ForegroundColor Cyan
Write-Host "🔑 Password: C+dental25" -ForegroundColor Yellow

# Use specific path to system scp if needed, or just scp
$scpCmd = "scp"
$scpArgs = @("-o", "StrictHostKeyChecking=no", "$tarFile", "$SSH_USER@$SERVER_IP`:$REMOTE_TMP")

Write-Host "Running: $scpCmd $scpArgs"
& $scpCmd $scpArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ SCP upload failed. Check password and try again."
    exit 1
}

# 4. SSH (Deployment)
Write-Host "🛠️  Deploying on Remote Server..." -ForegroundColor Cyan

$remoteCommands = @"
echo '--- Starting Remote Deployment ---'
mkdir -p $REMOTE_DIR
tar -xzf $REMOTE_TMP -C $REMOTE_DIR
echo '✅ Files Extracted'
sudo chown -R www-data:www-data $REMOTE_DIR/app/Core $REMOTE_DIR/api
sudo chmod +x $REMOTE_DIR/api/n8n.php
rm $REMOTE_TMP
echo '--- Deployment Complete ---'
"@ -replace "`n", " && "

$sshArgs = @("-o", "StrictHostKeyChecking=no", "$SSH_USER@$SERVER_IP", $remoteCommands)

Write-Host "Running: ssh ..."
& ssh $sshArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✨ Deployment Successfully Run!" -ForegroundColor Green
}
else {
    Write-Error "❌ Deployment commands failed on server."
}
