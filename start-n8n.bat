@echo off
echo ========================================
echo   Iniciando Entorno n8n - Produccion  
echo ========================================
echo.

cd /d "C:\Users\Thomas Tixerina\.gemini\antigravity\scratch\n8n-docker-v2"

echo [1/6] Deteniendo contenedores existentes...
docker-compose down
echo.

echo [2/6] Iniciando servicios de n8n...
docker-compose up -d

if %errorlevel% neq 0 (
    echo Error al iniciar los servicios.
    pause
    exit /b %errorlevel%
)

echo.
echo [3/6] Esperando a que los servicios esten listos (15s)...
timeout /t 15 /nobreak >nul

echo.
echo [4/6] Estado de los servicios:
docker-compose ps

echo.
echo [5/6] Intentando obtener URL de Cloudflare Tunnel...
echo Buscando en los logs...
docker logs n8n-tunnel > tunnel_logs.txt 2>&1
findstr "trycloudflare.com" tunnel_logs.txt

echo.
echo ========================================
echo   Si ves una URL arriba, esa es tu URL.
echo   Si no, revisa los logs con: docker logs n8n-tunnel
echo   Acceso local: http://localhost:5678
echo ========================================
echo.
pause
