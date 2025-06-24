#!/bin/bash
cd ../docker
echo "🚀 Starting development environment..."
docker-compose --profile tools --profile database up -d
echo "✅ Development environment started!"
echo "🔗 Services:"
echo "  - Traefik Dashboard: http://localhost:8090"
echo "  - Redis Commander: http://localhost:$(grep REDIS_COMMANDER_PORT .env | cut -d'=' -f2)"
echo "  - Adminer: http://localhost:$(grep ADMINER_PORT .env | cut -d'=' -f2)"
