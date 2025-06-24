#!/bin/bash

# Universal connection test script
# Tests all services without requiring specific programming language

echo "🧪 Testing Docker Infrastructure Connections..."
echo ""

cd "$(dirname "$0")/../docker"

# Check if services are running
echo "📊 Checking service status..."
docker-compose ps
echo ""

# Test Redis
echo "🔴 Testing Redis connection..."
if docker-compose exec -T redis redis-cli ping >/dev/null 2>&1; then
  echo "✅ Redis: Connected successfully"

  # Test basic operations
  docker-compose exec -T redis redis-cli set test-key "Hello Redis" >/dev/null
  REDIS_VALUE=$(docker-compose exec -T redis redis-cli get test-key 2>/dev/null | tr -d '\r\n')
  if [ "$REDIS_VALUE" = "Hello Redis" ]; then
    echo "✅ Redis: Read/Write operations working"
  else
    echo "⚠️  Redis: Read/Write operations failed"
  fi

  docker-compose exec -T redis redis-cli del test-key >/dev/null
else
  echo "❌ Redis: Connection failed"
fi

echo ""

# Test MQTT
echo "📡 Testing MQTT connection..."
if docker-compose exec -T mosquitto mosquitto_pub -h localhost -t test/topic -m "Hello MQTT" -u mqttuser -P mqttpass123 >/dev/null 2>&1; then
  echo "✅ MQTT: Connection and publish successful"
  echo "✅ MQTT: Authentication working (mqttuser/mqttpass123)"
else
  echo "❌ MQTT: Connection or authentication failed"
fi

echo ""

# Test PostgreSQL (if running)
if docker-compose ps | grep -q postgres; then
  echo "🐘 Testing PostgreSQL connection..."
  if docker-compose exec -T postgres pg_isready -U postgres >/dev/null 2>&1; then
    echo "✅ PostgreSQL: Connection successful"

    # Test database operations
    DB_TEST=$(docker-compose exec -T postgres psql -U postgres -d myapp -c "SELECT 1 as test;" 2>/dev/null | grep -c "1 row")
    if [ "$DB_TEST" -eq "1" ]; then
      echo "✅ PostgreSQL: Database 'myapp' accessible"
    else
      echo "⚠️  PostgreSQL: Database access issues"
    fi
  else
    echo "❌ PostgreSQL: Connection failed"
  fi
  echo ""
fi

# Test development tools
echo "🛠️  Testing development tools..."

# Test Redis Commander
if docker-compose ps | grep -q redis-commander; then
  if curl -s http://localhost:8081 >/dev/null 2>&1; then
    echo "✅ Redis Commander: Available at http://localhost:8081"
  else
    echo "⚠️  Redis Commander: Service running but not accessible"
  fi
else
  echo "ℹ️  Redis Commander: Not running (start with --profile tools)"
fi

# Test Adminer
if docker-compose ps | grep -q adminer; then
  if curl -s http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Adminer: Available at http://localhost:8080"
  else
    echo "⚠️  Adminer: Service running but not accessible"
  fi
else
  echo "ℹ️  Adminer: Not running (start with --profile tools)"
fi

echo ""

# Network test
echo "🌐 Testing internal network connectivity..."
if docker-compose exec -T redis ping -c 1 mosquitto >/dev/null 2>&1; then
  echo "✅ Internal network: Services can communicate"
else
  echo "⚠️  Internal network: Communication issues detected"
fi

echo ""

# Volume test
echo "💾 Testing data persistence..."
REDIS_DATA_DIR=$(docker volume inspect $(docker-compose config --volumes | grep redis) 2>/dev/null | grep Mountpoint | cut -d'"' -f4)
if [ -n "$REDIS_DATA_DIR" ] && [ -d "$REDIS_DATA_DIR" ]; then
  echo "✅ Redis data volume: $REDIS_DATA_DIR"
else
  echo "⚠️  Redis data volume: Location not found"
fi

MQTT_DATA_DIR=$(docker volume inspect $(docker-compose config --volumes | grep mosquitto_data) 2>/dev/null | grep Mountpoint | cut -d'"' -f4)
if [ -n "$MQTT_DATA_DIR" ] && [ -d "$MQTT_DATA_DIR" ]; then
  echo "✅ MQTT data volume: $MQTT_DATA_DIR"
else
  echo "⚠️  MQTT data volume: Location not found"
fi

echo ""
echo "🎯 Connection Summary:"
echo "  Redis: localhost:6379 (no auth)"
echo "  MQTT: localhost:1883 (mqttuser:mqttpass123)"
echo "  MQTT WebSocket: localhost:9001"
if docker-compose ps | grep -q postgres; then
  echo "  PostgreSQL: localhost:5432 (postgres:postgres123)"
fi
echo ""
echo "📚 Check README.md for language-specific connection examples!"
