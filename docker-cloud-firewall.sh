#!/bin/bash
# Docker Build Cloud Firewall Configuration Script
# This script configures firewall rules to allow Docker Build Cloud traffic

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo"
  exit 1
fi

echo "=== Configuring firewall for Docker Build Cloud access ==="

# Detect which firewall is in use (ufw or iptables)
if command -v ufw &> /dev/null; then
  echo "UFW firewall detected. Adding rules..."
  
  # Allow specific IP address for Docker Build Cloud
  echo "Allowing access to Docker Build Cloud IP: 3.211.38.21"
  ufw allow out to 3.211.38.21
  
  # Allow HTTPS connections to required domains
  echo "Allowing HTTPS access to required Docker domains:"
  echo "- auth.docker.io"
  echo "- build-cloud.docker.com"
  echo "- hub.docker.com"
  
  # UFW doesn't directly support domain names, so we use port 443 (HTTPS)
  ufw allow out to any port 443 proto tcp
  
  # Enable the firewall if not already enabled
  if ! ufw status | grep -q "Status: active"; then
    echo "Enabling UFW firewall..."
    ufw --force enable
  fi
  
  echo "UFW configuration complete."
  echo "UFW Status:"
  ufw status

elif command -v iptables &> /dev/null; then
  echo "iptables detected. Adding rules..."
  
  # Allow specific IP for Docker Build Cloud
  echo "Allowing access to Docker Build Cloud IP: 3.211.38.21"
  iptables -A OUTPUT -d 3.211.38.21 -j ACCEPT
  
  # Allow HTTPS connections to required domains
  echo "Allowing HTTPS access to required Docker domains"
  iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
  
  # Save the iptables rules
  if command -v iptables-save &> /dev/null; then
    echo "Saving iptables rules..."
    if [ -d "/etc/iptables" ]; then
      iptables-save > /etc/iptables/rules.v4
    else
      echo "Warning: iptables-save directory not found. Rules will not persist after reboot."
      echo "To make rules persistent, save them to your distribution's firewall config."
    fi
  fi
  
  echo "iptables configuration complete."
  echo "Current iptables rules:"
  iptables -L OUTPUT -n

else
  echo "No supported firewall detected. Please manually configure your firewall to allow:"
  echo "1. Outbound access to IP: 3.211.38.21"
  echo "2. Outbound HTTPS (port 443) access to:"
  echo "   - auth.docker.io"
  echo "   - build-cloud.docker.com"
  echo "   - hub.docker.com"
fi

echo ""
echo "=== Configuration Notes ==="
echo "Docker Build Cloud requires access to the following:"
echo "- IP Address: 3.211.38.21"
echo "- Domains (HTTPS/443):"
echo "  - auth.docker.io"
echo "  - build-cloud.docker.com"
echo "  - hub.docker.com"
echo ""
echo "If you're behind a corporate firewall, please provide this information to your network administrator."
echo "For specialized environments, you might need to add DNS resolution rules as well."
echo ""
echo "After configuring the firewall, try running Docker Build Cloud commands again:"
echo "docker buildx create --driver cloud username/buildername"