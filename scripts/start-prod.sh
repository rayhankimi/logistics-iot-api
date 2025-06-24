#!/bin/bash
cd ../docker
echo "🚀 Starting production environment..."
docker-compose --profile proxy up -d
echo "✅ Production environment started!"
echo "🔗 Access via:"
echo "  - Redis: redis.localhost"
echo "  - MQTT: mqtt.localhost"
echo "  - InfluxDB: influxdb.localhost"
