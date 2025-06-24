#!/bin/bash
cd ../docker
if [ -z "$1" ]; then
    echo "📋 Available services:"
    docker-compose config --services
    echo ""
    echo "Usage: ./scripts/logs.sh <service_name>"
    echo "Example: ./scripts/logs.sh redis"
else
    docker-compose logs -f "$1"
fi
