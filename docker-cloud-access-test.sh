#!/bin/bash
# Docker Build Cloud Connectivity Test
# This script tests connectivity to required Docker Build Cloud endpoints

echo "=== Testing Docker Build Cloud Connectivity ==="
echo "This script will check if your system can reach Docker Build Cloud services."
echo ""

# Function to test TCP connectivity
test_tcp_connection() {
  local host=$1
  local port=$2
  local timeout=5
  
  echo -n "Testing connection to $host:$port... "
  if nc -z -w $timeout $host $port 2>/dev/null; then
    echo "SUCCESS"
    return 0
  else
    echo "FAILED"
    return 1
  fi
}

# Function to test HTTP/HTTPS connectivity
test_http_connection() {
  local url=$1
  local timeout=10
  
  echo -n "Testing connection to $url... "
  if curl --silent --head --fail --max-time $timeout "$url" >/dev/null; then
    echo "SUCCESS"
    return 0
  else
    echo "FAILED"
    return 1
  fi
}

# Function to check DNS resolution
check_dns() {
  local domain=$1
  
  echo -n "Resolving DNS for $domain... "
  if host "$domain" >/dev/null 2>&1; then
    echo "SUCCESS"
    return 0
  else
    echo "FAILED"
    return 1
  fi
}

# Check if we have required tools
if ! command -v nc &>/dev/null || ! command -v curl &>/dev/null || ! command -v host &>/dev/null; then
  echo "Installing required tools for testing..."
  sudo apt-get update
  sudo apt-get install -y netcat curl dnsutils
fi

echo "=== Testing DNS Resolution ==="
dns_success=true
check_dns "auth.docker.io" || dns_success=false
check_dns "build-cloud.docker.com" || dns_success=false
check_dns "hub.docker.com" || dns_success=false
echo ""

echo "=== Testing Direct IP Connectivity ==="
test_tcp_connection "3.211.38.21" 443
echo ""

echo "=== Testing HTTPS Endpoints ==="
https_success=true
test_http_connection "https://auth.docker.io" || https_success=false
test_http_connection "https://build-cloud.docker.com" || https_success=false
test_http_connection "https://hub.docker.com" || https_success=false
echo ""

echo "=== Testing Docker Authentication ==="
echo -n "Checking Docker login status... "
if docker info 2>/dev/null | grep -q "Username"; then
  echo "LOGGED IN"
else
  echo "NOT LOGGED IN"
  echo "You should log in to Docker Hub with: docker login"
fi
echo ""

# Summary
echo "=== Connectivity Test Summary ==="
if [ "$dns_success" = true ] && [ "$https_success" = true ]; then
  echo "All connectivity tests PASSED. Your system should be able to access Docker Build Cloud."
  echo "If you're still having issues, please check:"
  echo "1. Docker version (should be 24.0.0 or later)"
  echo "2. Docker Buildx version (should be 0.10.0 or later)"
  echo "3. Docker Hub subscription status (Build Cloud requires a subscription or trial)"
else
  echo "Some connectivity tests FAILED. Your system may not be able to access Docker Build Cloud."
  echo "Please review the failed tests above and ensure your firewall allows the required connections."
  echo "You may need to:"
  echo "1. Configure your firewall (run the docker-cloud-firewall.sh script)"
  echo "2. Check your network connection"
  echo "3. Contact your network administrator if behind a corporate firewall"
fi