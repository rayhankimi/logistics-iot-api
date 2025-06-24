#!/bin/bash
cd ../docker
echo "📊 Service Status:"
docker-compose ps
echo ""
echo "🌐 Network Status:"
docker network ls | grep $(grep COMPOSE_PROJECT_NAME .env | cut -d'=' -f2)
