$ErrorActionPreference = "Stop"

$SERVER_IP = "100.101.161.29"
$SSH_USER = "ttijerina"
$REMOTE_PATH = "/var/www/miconsul" # Assumed path, adjust as needed

Write-Host "📦 Packaging Modernization Files..." -ForegroundColor Cyan

# Create a temporary zip
$source = ".\miconsul_codebase\*"
$destination = ".\miconsul_modernization.zip"
if (Test-Path $destination) { Remove-Item $destination }

Compress-Archive -Path $source -DestinationPath $destination

Write-Host "🚀 Deploying to $SERVER_IP..." -ForegroundColor Cyan
Write-Host "ℹ️  Password is: C+dental25" -ForegroundColor Yellow

# check if scp is available
if (Get-Command scp -ErrorAction SilentlyContinue) {
    # 1. Upload Zip
    Write-Host "Uploading zip..."
    $absPath = (Resolve-Path $destination).Path
    $scpTarget = "$SSH_USER@$SERVER_IP" + ":/tmp/miconsul_modernization.zip"
    # Using simplified options to avoid usage errors
    scp -o StrictHostKeyChecking=no "$absPath" $scpTarget
    
    # 2. Extract and Overwrite (Remote Commands)
    Write-Host "Extracting and updating permissions..."
    $commands = "
        echo 'Extracting files...';
        unzip -o /tmp/miconsul_modernization.zip -d $REMOTE_PATH;
        echo 'Setting permissions...';
        sudo chown -R www-data:www-data $REMOTE_PATH/app/Core $REMOTE_PATH/api;
        sudo chmod +x $REMOTE_PATH/api/n8n.php;
        echo 'Deployment Complete!';
        rm /tmp/miconsul_modernization.zip
    "
    
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=NUL "$SSH_USER@$SERVER_IP" $commands
    
    Write-Host "✅ Deployment Successful!" -ForegroundColor Green
}
else {
    Write-Host "❌ 'scp' command not found. Please assure OpenSSH Client is installed." -ForegroundColor Red
}
