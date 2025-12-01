#!/bin/bash

# QR Code Generator - Nginx Reverse Proxy Setup
# This script configures Nginx as a reverse proxy for the QR Generator

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
echo "   Nginx Reverse Proxy Setup"
echo "=========================================="
echo ""

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run with sudo"
    echo "Usage: sudo ./setup-nginx.sh"
    exit 1
fi

# Check if nginx is installed
if ! command -v nginx &> /dev/null; then
    print_warning "Nginx is not installed"
    read -p "Install Nginx now? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        print_info "Installing Nginx..."
        apt-get update
        apt-get install -y nginx
        print_success "Nginx installed"
    else
        print_error "Nginx is required for reverse proxy"
        exit 1
    fi
fi

# Ask for configuration type
echo ""
echo "Choose setup type:"
echo "  1) Domain name (e.g., qr.yourdomain.com)"
echo "  2) IP address only"
echo ""
read -p "Enter choice (1 or 2): " choice

if [ "$choice" = "1" ]; then
    # Domain setup
    echo ""
    read -p "Enter your domain name (e.g., qr.yourdomain.com): " DOMAIN
    
    if [ -z "$DOMAIN" ]; then
        print_error "Domain name cannot be empty"
        exit 1
    fi
    
    SERVER_NAME="$DOMAIN"
    SETUP_TYPE="domain"
    
elif [ "$choice" = "2" ]; then
    # IP setup
    SERVER_IP=$(hostname -I | awk '{print $1}')
    print_info "Detected server IP: $SERVER_IP"
    echo ""
    read -p "Use this IP? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        read -p "Enter your server IP: " SERVER_IP
    fi
    
    SERVER_NAME="$SERVER_IP"
    SETUP_TYPE="ip"
else
    print_error "Invalid choice"
    exit 1
fi

# Create nginx configuration
NGINX_CONFIG="/etc/nginx/sites-available/qr-generator"

print_info "Creating Nginx configuration..."

cat > "$NGINX_CONFIG" << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $SERVER_NAME;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Logging
    access_log /var/log/nginx/qr-generator-access.log;
    error_log /var/log/nginx/qr-generator-error.log;
}
EOF

print_success "Configuration created"

# Enable site
print_info "Enabling site..."
ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/qr-generator

# Test nginx configuration
print_info "Testing Nginx configuration..."
if nginx -t; then
    print_success "Configuration is valid"
else
    print_error "Configuration has errors!"
    exit 1
fi

# Reload nginx
print_info "Reloading Nginx..."
systemctl reload nginx

print_success "Nginx configured successfully!"

# Configure firewall
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        print_info "Configuring UFW firewall..."
        ufw allow 'Nginx Full'
        print_success "Firewall configured"
    fi
fi

echo ""
echo "=========================================="
print_success "Setup Complete!"
echo "=========================================="
echo ""

if [ "$SETUP_TYPE" = "domain" ]; then
    echo "🌐 Access your QR Generator at:"
    echo "   http://$DOMAIN"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Ensure DNS is pointing to this server"
    echo "   2. Install SSL certificate with certbot:"
    echo "      sudo apt install certbot python3-certbot-nginx"
    echo "      sudo certbot --nginx -d $DOMAIN"
    echo ""
else
    echo "🌐 Access your QR Generator at:"
    echo "   http://$SERVER_NAME"
    echo ""
fi

echo "📊 Useful commands:"
echo "   Check Nginx status:  sudo systemctl status nginx"
echo "   View access logs:    sudo tail -f /var/log/nginx/qr-generator-access.log"
echo "   View error logs:     sudo tail -f /var/log/nginx/qr-generator-error.log"
echo "   Reload Nginx:        sudo systemctl reload nginx"
echo ""
