@echo off
echo ==========================================
echo QR Code Generator - Docker Deployment
echo ==========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not running. Please start Docker Desktop.
    pause
    exit /b 1
)

echo Docker is running
echo.

REM Build and start the container
echo Building and starting QR Code Generator...
echo.

docker-compose up -d --build

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo QR Code Generator is now running!
    echo ==========================================
    echo.
    echo Access it at: http://localhost:3000
    echo.
    echo To access from other devices on your network:
    echo Find your IP address and use: http://YOUR_IP:3000
    echo.
    echo Useful commands:
    echo   View logs:     docker-compose logs -f
    echo   Stop app:      docker-compose down
    echo   Restart app:   docker-compose restart
    echo.
) else (
    echo.
    echo Error: Failed to start the application
    echo Check the logs with: docker-compose logs
)

pause
