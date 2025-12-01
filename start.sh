#!/bin/bash

echo "=========================================="
echo "QR Code Generator - Docker Deployment"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker Desktop."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Build and start the container
echo "🔨 Building and starting QR Code Generator..."
echo ""

docker-compose up -d --build

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ QR Code Generator is now running!"
    echo "=========================================="
    echo ""
    echo "🌐 Access it at: http://localhost:3000"
    echo ""
    echo "To access from other devices on your network:"
    echo "Find your IP address and use: http://YOUR_IP:3000"
    echo ""
    echo "Useful commands:"
    echo "  View logs:     docker-compose logs -f"
    echo "  Stop app:      docker-compose down"
    echo "  Restart app:   docker-compose restart"
    echo ""
else
    echo ""
    echo "❌ Error: Failed to start the application"
    echo "Check the logs with: docker-compose logs"
fi
