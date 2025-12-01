#!/bin/bash

# Fast deployment using development mode (much faster than production build)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo "=========================================="
echo "   QR Generator - FAST Deployment"
echo "   Development Mode"
echo "=========================================="
echo ""

# Stop any existing container
print_info "Stopping existing containers..."
docker compose down 2>/dev/null || true

# Create development docker-compose
cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  qr-generator:
    image: node:18-alpine
    container_name: qr-generator
    working_dir: /app
    ports:
      - "3000:3000"
    volumes:
      - ./:/app
    command: sh -c "npm install && npm start"
    restart: unless-stopped
    environment:
      - NODE_ENV=development
      - CHOKIDAR_USEPOLLING=true
EOF

print_info "Starting in development mode..."
docker compose -f docker-compose.dev.yml up -d

print_info "Waiting for npm install to complete..."
sleep 5

echo ""
print_success "Deployment started!"
echo ""
echo "📊 Follow the logs:"
echo "   docker compose -f docker-compose.dev.yml logs -f"
echo ""
echo "🌐 Access will be available at:"
echo "   http://$(hostname -I | awk '{print $1}'):3000"
echo ""
echo "⚡ This is DEV mode - faster but uses more resources"
echo ""
