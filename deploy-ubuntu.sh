#!/bin/bash

# QR Code Generator - Ubuntu Server Deployment Script
# This script automates the complete deployment process

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="qr-generator"
APP_PORT="3000"
APP_DIR="$(pwd)"

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Print banner
echo ""
echo "=========================================="
echo "   QR Code Generator Deployment"
echo "   Ubuntu Server Edition"
echo "=========================================="
echo ""

# Check if running with sudo (optional but recommended)
if [ "$EUID" -eq 0 ]; then 
    print_warning "Running as root. Consider using a regular user with sudo."
fi

# Check if Docker is installed
print_status "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    echo ""
    echo "Install Docker with:"
    echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "  sudo sh get-docker.sh"
    echo "  sudo usermod -aG docker \$USER"
    exit 1
fi
print_success "Docker is installed"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running!"
    echo ""
    echo "Start Docker with:"
    echo "  sudo systemctl start docker"
    exit 1
fi
print_success "Docker is running"

# Check if Docker Compose is available
print_status "Checking Docker Compose..."
if ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not available!"
    echo ""
    echo "Install Docker Compose plugin:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install docker-compose-plugin"
    exit 1
fi
print_success "Docker Compose is available"

# Check if port is available
print_status "Checking if port $APP_PORT is available..."
if sudo lsof -Pi :$APP_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    print_warning "Port $APP_PORT is already in use!"
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Deployment cancelled"
        exit 1
    fi
else
    print_success "Port $APP_PORT is available"
fi

# Stop existing container if running
print_status "Checking for existing container..."
if docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
    print_warning "Existing container found. Stopping and removing..."
    docker compose down
    print_success "Existing container removed"
else
    print_success "No existing container found"
fi

# Build and start the application
print_status "Building Docker image..."
docker compose build

print_status "Starting application..."
docker compose up -d

# Wait for container to be healthy
print_status "Waiting for application to start..."
sleep 5

# Check if container is running
if docker ps --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
    print_success "Container is running"
else
    print_error "Container failed to start!"
    echo ""
    echo "Check logs with: docker compose logs"
    exit 1
fi

# Get server IP addresses
print_status "Detecting network interfaces..."
SERVER_IPS=$(hostname -I | tr ' ' '\n' | grep -v '^$')

echo ""
echo "=========================================="
print_success "QR Code Generator Deployed Successfully!"
echo "=========================================="
echo ""
echo "📱 Access URLs:"
echo ""
echo "   Local access:"
echo "   🔗 http://localhost:$APP_PORT"
echo ""
echo "   Network access:"
while IFS= read -r ip; do
    echo "   🔗 http://$ip:$APP_PORT"
done <<< "$SERVER_IPS"
echo ""

# Check firewall status
print_status "Checking firewall configuration..."
if command -v ufw &> /dev/null; then
    if sudo ufw status | grep -q "Status: active"; then
        print_warning "UFW firewall is active"
        if sudo ufw status | grep -q "$APP_PORT"; then
            print_success "Port $APP_PORT is allowed in UFW"
        else
            print_warning "Port $APP_PORT is NOT allowed in UFW"
            echo ""
            read -p "Allow port $APP_PORT through firewall? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                sudo ufw allow $APP_PORT/tcp
                print_success "Port $APP_PORT allowed through firewall"
            fi
        fi
    else
        print_success "UFW firewall is inactive"
    fi
else
    print_warning "UFW not found - firewall status unknown"
fi

echo ""
echo "🛠️  Management Commands:"
echo ""
echo "   View logs:        docker compose logs -f"
echo "   Stop app:         docker compose down"
echo "   Restart app:      docker compose restart"
echo "   Check status:     docker compose ps"
echo "   View stats:       docker stats $APP_NAME"
echo ""

echo "📊 Container Status:"
docker compose ps
echo ""

# Offer to show logs
read -p "Show application logs? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    print_status "Showing logs (Press Ctrl+C to exit)..."
    echo ""
    sleep 1
    docker compose logs -f
fi

print_success "Deployment complete!"
