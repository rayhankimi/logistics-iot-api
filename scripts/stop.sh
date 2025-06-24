#!/bin/bash
cd ../docker
echo "🛑 Stopping all services..."
docker-compose down
echo "✅ All services stopped!"
