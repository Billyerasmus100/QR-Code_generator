#!/bin/bash

# QR Code Generator - Systemd Service Installation
# This script installs the app as a systemd service

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo "=========================================="
echo "   QR Generator - Systemd Setup"
echo "=========================================="
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run with sudo"
    echo "Usage: sudo ./install-service.sh"
    exit 1
fi

# Get the actual user (not root when using sudo)
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
APP_DIR="$ACTUAL_HOME/qr-generator"

print_info "Installing service for user: $ACTUAL_USER"
print_info "Application directory: $APP_DIR"

# Check if directory exists
if [ ! -d "$APP_DIR" ]; then
    print_error "Directory $APP_DIR does not exist!"
    echo ""
    echo "Please ensure qr-generator is installed at: $APP_DIR"
    exit 1
fi

# Create service file
SERVICE_FILE="/etc/systemd/system/qr-generator.service"

print_info "Creating systemd service file..."

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=QR Code Generator
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
User=$ACTUAL_USER
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

print_success "Service file created at $SERVICE_FILE"

# Reload systemd
print_info "Reloading systemd daemon..."
systemctl daemon-reload

# Enable service
print_info "Enabling service..."
systemctl enable qr-generator.service

print_success "Service installed and enabled!"

echo ""
echo "=========================================="
echo "   Service Management Commands"
echo "=========================================="
echo ""
echo "Start service:     sudo systemctl start qr-generator"
echo "Stop service:      sudo systemctl stop qr-generator"
echo "Restart service:   sudo systemctl restart qr-generator"
echo "Service status:    sudo systemctl status qr-generator"
echo "View logs:         sudo journalctl -u qr-generator -f"
echo "Disable service:   sudo systemctl disable qr-generator"
echo ""

read -p "Start the service now? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    print_info "Starting service..."
    systemctl start qr-generator
    sleep 2
    systemctl status qr-generator --no-pager
    echo ""
    print_success "Service started!"
fi

echo ""
print_success "Installation complete!"
echo ""
echo "The QR Generator will now:"
echo "  ✓ Start automatically on boot"
echo "  ✓ Restart automatically if it crashes"
echo "  ✓ Can be managed with systemctl commands"
echo ""
