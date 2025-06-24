#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"

    echo -e "${CYAN}$prompt${NC}"
    echo -e "${YELLOW}Default: $default${NC}"
    read -p "Enter value (or press Enter for default): " input

    if [ -z "$input" ]; then
        eval "$var_name='$default'"
        echo -e "${GREEN}Using default: $default${NC}"
    else
        eval "$var_name='$input'"
        echo -e "${GREEN}Set to: $input${NC}"
    fi
    echo ""
}

# Function to prompt for password with confirmation
prompt_password() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"

    echo -e "${CYAN}$prompt${NC}"
    echo -e "${YELLOW}Default: $default${NC}"
    read -s -p "Enter password (or press Enter for default): " password1
    echo ""

    if [ -z "$password1" ]; then
        eval "$var_name='$default'"
        echo -e "${GREEN}Using default password${NC}"
    else
        read -s -p "Confirm password: " password2
        echo ""

        if [ "$password1" = "$password2" ]; then
            eval "$var_name='$password1'"
            echo -e "${GREEN}Password set successfully${NC}"
        else
            echo -e "${RED}Passwords don't match. Using default.${NC}"
            eval "$var_name='$default'"
        fi
    fi
    echo ""
}

echo -e "${GREEN}🎉 Moving to root folder..${NC}"
cd ..

# Setup script for Docker infrastructure with network separation
echo -e "${BLUE}🔧 Setting up Docker Infrastructure with Network Separation...${NC}"
echo ""

# Create directory structure
echo -e "${PURPLE}📁 Creating directory structure...${NC}"
mkdir -p docker/configs/{redis,mosquitto,postgres,influxdb}
mkdir -p scripts
mkdir -p cmd internal pkg
echo -e "${GREEN}✅ Directory structure created${NC}"
echo ""

# Interactive configuration
echo -e "${BLUE}🔧 Configuration Setup${NC}"
echo -e "${YELLOW}Please provide configuration values (press Enter to use defaults):${NC}"
echo ""

# Project settings
prompt_with_default "Project Name:" "mygoapp" "PROJECT_NAME"
prompt_with_default "Timezone:" "Asia/Jakarta" "TIMEZONE"

# Redis settings
echo -e "${BLUE}📡 Redis Configuration${NC}"
prompt_with_default "Redis Port:" "6379" "REDIS_PORT"
prompt_with_default "Redis Max Memory:" "256mb" "REDIS_MAX_MEMORY"

# MQTT settings
echo -e "${BLUE}📡 MQTT Configuration${NC}"
prompt_with_default "MQTT Port:" "1883" "MQTT_PORT"
prompt_with_default "MQTT WebSocket Port:" "9001" "MQTT_WS_PORT"
prompt_with_default "MQTT Username:" "mqttuser" "MQTT_USERNAME"
prompt_password "MQTT Password:" "mqttpass123" "MQTT_PASSWORD"

# InfluxDB settings
echo -e "${BLUE}📊 InfluxDB Configuration${NC}"
prompt_with_default "InfluxDB Port:" "8086" "INFLUXDB_PORT"
prompt_with_default "InfluxDB Username:" "admin" "INFLUXDB_USERNAME"
prompt_password "InfluxDB Password:" "admin123" "INFLUXDB_PASSWORD"
prompt_with_default "InfluxDB Organization:" "myorg" "INFLUXDB_ORG"
prompt_with_default "InfluxDB Bucket:" "mybucket" "INFLUXDB_BUCKET"

# Development tools
echo -e "${BLUE}🛠️ Development Tools Configuration${NC}"
prompt_with_default "Redis Commander Port:" "8081" "REDIS_COMMANDER_PORT"
prompt_with_default "Adminer Port:" "8080" "ADMINER_PORT"

# Database settings
echo -e "${BLUE}🗄️ PostgreSQL Configuration${NC}"
prompt_with_default "Database Name:" "myapp" "POSTGRES_DB"
prompt_with_default "Database Username:" "postgres" "POSTGRES_USER"
prompt_password "Database Password:" "postgres123" "POSTGRES_PASSWORD"
prompt_with_default "Database Port:" "5432" "POSTGRES_PORT"

# Create configuration files
echo -e "${PURPLE}📝 Creating configuration files...${NC}"

# Redis configuration
cat >docker/configs/redis/redis.conf <<EOF
# Redis configuration for production
bind 0.0.0.0
port 6379
protected-mode no
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile ""
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir ./
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-ping-replica-period 10
repl-timeout 60
repl-disable-tcp-nodelay no
repl-backlog-size 1mb
repl-backlog-ttl 3600
replica-priority 100
maxclients 10000
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
EOF

# Mosquitto configuration
cat >docker/configs/mosquitto/mosquitto.conf <<EOF
# Mosquitto MQTT Broker Configuration
listener 1883 0.0.0.0
protocol mqtt

listener 9001 0.0.0.0
protocol websockets

allow_anonymous false
password_file /mosquitto/config/passwd

persistence true
persistence_location /mosquitto/data/

log_dest file /mosquitto/log/mosquitto.log
log_dest stdout

log_type error
log_type warning
log_type notice
log_type information

connection_messages true
log_timestamp true

# Security settings
max_connections 1000
max_inflight_messages 100
max_queued_messages 1000

# WebSocket settings
websockets_log_level 255
EOF

# Create MQTT password file
echo -e "${PURPLE}🔐 Creating MQTT password file...${NC}"

# Check if mosquitto_passwd is available
if command -v mosquitto_passwd &>/dev/null; then
    # Native mosquitto tools available
    mosquitto_passwd -c -b docker/configs/mosquitto/passwd "$MQTT_USERNAME" "$MQTT_PASSWORD"
    echo -e "${GREEN}✅ MQTT password file created with user: $MQTT_USERNAME${NC}"
else
    # Alternative 1: Using OpenSSL (most common)
    echo -e "${YELLOW}Using OpenSSL to generate MQTT password file...${NC}"
    HASHED_PASSWORD=$(openssl passwd -6 "$MQTT_PASSWORD")
    echo "$MQTT_USERNAME:$HASHED_PASSWORD" > docker/configs/mosquitto/passwd
    echo -e "${GREEN}✅ MQTT password file created with user: $MQTT_USERNAME${NC}"

    # Alternative 2: Using Python (if available)
    # echo -e "${YELLOW}Using Python to generate MQTT password file...${NC}"
    # python3 -c "
    # import hashlib, os, base64
    # salt = os.urandom(12)
    # password = '$MQTT_PASSWORD'.encode('utf-8')
    # hash_obj = hashlib.pbkdf2_hmac('sha512', password, salt, 101)
    # hash_b64 = base64.b64encode(salt + hash_obj).decode('ascii')
    # print('$MQTT_USERNAME:\$7\$101\$' + hash_b64)
    # " > docker/configs/mosquitto/passwd
    # echo -e "${GREEN}✅ MQTT password file created with user: $MQTT_USERNAME${NC}"

    # Alternative 3: Using htpasswd (if available)
    # echo -e "${YELLOW}Using htpasswd to generate MQTT password file...${NC}"
    # htpasswd -c -B docker/configs/mosquitto/passwd "$MQTT_USERNAME" <<< "$MQTT_PASSWORD"
    # echo -e "${GREEN}✅ MQTT password file created with user: $MQTT_USERNAME${NC}"

    # Alternative 4: Simple SHA256 (less secure, but works)
    # echo -e "${YELLOW}Using SHA256 to generate MQTT password file...${NC}"
    # HASHED_PASSWORD=$(echo -n "$MQTT_PASSWORD" | sha256sum | cut -d' ' -f1)
    # echo "$MQTT_USERNAME:$HASHED_PASSWORD" > docker/configs/mosquitto/passwd
    # echo -e "${GREEN}✅ MQTT password file created with user: $MQTT_USERNAME${NC}"
fi

# Set correct permissions
chmod 644 docker/configs/mosquitto/passwd 2>/dev/null || true
chmod 644 docker/configs/redis/redis.conf 2>/dev/null || true
chmod 644 docker/configs/mosquitto/mosquitto.conf 2>/dev/null || true

# Create .env file for docker-compose with user inputs
echo -e "${PURPLE}📝 Creating .env file...${NC}"
cat >docker/.env <<EOF
# Environment variables for Docker Compose
# Generated on $(date)
COMPOSE_PROJECT_NAME=$PROJECT_NAME
TZ=$TIMEZONE

# Redis settings
REDIS_PORT=$REDIS_PORT
REDIS_MAX_MEMORY=$REDIS_MAX_MEMORY

# MQTT settings
MQTT_PORT=$MQTT_PORT
MQTT_WS_PORT=$MQTT_WS_PORT
MQTT_USERNAME=$MQTT_USERNAME
MQTT_PASSWORD=$MQTT_PASSWORD

# InfluxDB settings
INFLUXDB_PORT=$INFLUXDB_PORT
INFLUXDB_USERNAME=$INFLUXDB_USERNAME
INFLUXDB_PASSWORD=$INFLUXDB_PASSWORD
INFLUXDB_ORG=$INFLUXDB_ORG
INFLUXDB_BUCKET=$INFLUXDB_BUCKET

# Development tools
REDIS_COMMANDER_PORT=$REDIS_COMMANDER_PORT
ADMINER_PORT=$ADMINER_PORT

# Database settings
POSTGRES_DB=$POSTGRES_DB
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_PORT=$POSTGRES_PORT
EOF

cp docker/.env .env

echo -e "${GREEN}✅ Created .env file with your configuration${NC}"

# Create Docker management scripts
cat >scripts/start-dev.sh <<'EOF'
#!/bin/bash
cd ../docker
echo "🚀 Starting development environment..."
docker-compose --profile tools --profile database up -d
echo "✅ Development environment started!"
echo "🔗 Services:"
echo "  - Traefik Dashboard: http://localhost:8090"
echo "  - Redis Commander: http://localhost:$(grep REDIS_COMMANDER_PORT .env | cut -d'=' -f2)"
echo "  - Adminer: http://localhost:$(grep ADMINER_PORT .env | cut -d'=' -f2)"
EOF

cat >scripts/start-prod.sh <<'EOF'
#!/bin/bash
cd ../docker
echo "🚀 Starting production environment..."
docker-compose --profile proxy up -d
echo "✅ Production environment started!"
echo "🔗 Access via:"
echo "  - Redis: redis.localhost"
echo "  - MQTT: mqtt.localhost"
echo "  - InfluxDB: influxdb.localhost"
EOF

cat >scripts/stop.sh <<'EOF'
#!/bin/bash
cd ../docker
echo "🛑 Stopping all services..."
docker-compose down
echo "✅ All services stopped!"
EOF

cat >scripts/logs.sh <<'EOF'
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
EOF

cat >scripts/status.sh <<'EOF'
#!/bin/bash
cd ../docker
echo "📊 Service Status:"
docker-compose ps
echo ""
echo "🌐 Network Status:"
docker network ls | grep $(grep COMPOSE_PROJECT_NAME .env | cut -d'=' -f2)
EOF

# Make scripts executable
chmod +x scripts/*.sh

echo -e "${GREEN}✅ Created management scripts${NC}"

# Create .gitignore additions
cat >>.gitignore <<EOF

# Docker volumes and logs
docker/volumes/
docker/logs/
*.log

# Environment files
.env.local
.env.*.local
docker/.env.backup

# Configuration backups
docker/configs/*/backup/
EOF

echo -e "${GREEN}✅ Updated .gitignore${NC}"

# Create backup of .env
cp docker/.env docker/.env.backup
echo -e "${GREEN}✅ Created .env backup${NC}"

# Create comprehensive README
cat >README.md <<EOF
# Docker Infrastructure with Network Separation

This project provides a production-ready Docker infrastructure with proper network isolation and security.

## 🏗️ Architecture

### Network Separation
- **Frontend Network** (172.20.0.0/24): External access via Traefik
- **Backend Network** (172.21.0.0/24): Application services (MQTT)
- **Database Network** (172.22.0.0/24): Isolated databases (PostgreSQL, InfluxDB)
- **Cache Network** (172.23.0.0/24): Isolated cache services (Redis)
- **Admin Network** (172.24.0.0/24): Management tools (Adminer, Redis Commander)

### Services
- **Traefik**: Reverse proxy with automatic service discovery
- **Redis**: In-memory cache with persistence
- **MQTT (Mosquitto)**: Message broker with WebSocket support
- **PostgreSQL**: Relational database
- **InfluxDB**: Time-series database
- **Development Tools**: Adminer, Redis Commander

## 🚀 Quick Start

### Development Environment
\`\`\`bash
# Start with all tools
./scripts/start-dev.sh

# Or manually
cd docker
docker-compose --profile tools --profile database up -d
\`\`\`

### Production Environment
\`\`\`bash
# Start with Traefik proxy
./scripts/start-prod.sh

# Or manually
cd docker
docker-compose --profile proxy up -d
\`\`\`

### Individual Services
\`\`\`bash
# Redis only
docker-compose up -d redis

# MQTT only
docker-compose up -d mosquitto

# Database services
docker-compose --profile database up -d
\`\`\`

## 🔗 Service Access

### Direct Access (Development)
- **Redis**: \`localhost:$REDIS_PORT\`
- **MQTT**: \`localhost:$MQTT_PORT\` (WebSocket: \`$MQTT_WS_PORT\`)
- **PostgreSQL**: \`localhost:$POSTGRES_PORT\`
- **InfluxDB**: \`localhost:$INFLUXDB_PORT\`
- **Redis Commander**: http://localhost:$REDIS_COMMANDER_PORT
- **Adminer**: http://localhost:$ADMINER_PORT

### Via Traefik (Production)
- **Traefik Dashboard**: http://traefik.localhost:8090
- **Redis**: redis.localhost
- **MQTT**: mqtt.localhost
- **InfluxDB**: influxdb.localhost
- **Redis Commander**: redis-commander.localhost
- **Adminer**: adminer.localhost

## 📋 Management Commands

\`\`\`bash
# Check service status
./scripts/status.sh

# View logs
./scripts/logs.sh redis
./scripts/logs.sh mosquitto

# Stop all services
./scripts/stop.sh

# Remove all data (⚠️ destructive)
cd docker && docker-compose down -v
\`\`\`

## 🔧 Configuration

### Environment Variables
All configuration is stored in \`docker/.env\`:
- Project settings (name, timezone)
- Service ports and credentials
- Resource limits

### Service Configurations
- Redis: \`docker/configs/redis/redis.conf\`
- MQTT: \`docker/configs/mosquitto/mosquitto.conf\`
- MQTT Users: \`docker/configs/mosquitto/passwd\`

### Network Security
- Database networks are isolated (\`internal: true\`)
- Cache networks are isolated
- Admin tools have controlled access to required networks
- Traefik acts as the only entry point for external traffic

## 🔐 Security Features

1. **Network Isolation**: Services can't communicate across networks unless explicitly allowed
2. **No Direct Database Access**: Databases are only accessible through admin tools or applications
3. **Authentication**: MQTT requires username/password
4. **Resource Limits**: Redis has memory limits
5. **Health Checks**: All services have health monitoring

## 📚 Language Examples

### Go
\`\`\`go
// Redis
rdb := redis.NewClient(&redis.Options{
    Addr: "localhost:$REDIS_PORT",
})

// MQTT
opts := mqtt.NewClientOptions()
opts.AddBroker("tcp://localhost:$MQTT_PORT")
opts.SetUsername("$MQTT_USERNAME")
opts.SetPassword("$MQTT_PASSWORD")

// PostgreSQL
db, err := sql.Open("postgres",
    "host=localhost port=$POSTGRES_PORT user=$POSTGRES_USER "+
    "password=$POSTGRES_PASSWORD dbname=$POSTGRES_DB sslmode=disable")
\`\`\`

### Python
\`\`\`python
# Redis
import redis
r = redis.Redis(host='localhost', port=$REDIS_PORT, db=0)

# MQTT
import paho.mqtt.client as mqtt
client = mqtt.Client()
client.username_pw_set("$MQTT_USERNAME", "$MQTT_PASSWORD")
client.connect("localhost", $MQTT_PORT, 60)

# PostgreSQL
import psycopg2
conn = psycopg2.connect(
    host="localhost",
    port=$POSTGRES_PORT,
    database="$POSTGRES_DB",
    user="$POSTGRES_USER",
    password="$POSTGRES_PASSWORD"
)
\`\`\`

## 🔄 Reconfiguration

To modify configuration:
\`\`\`bash
# Re-run setup script
./scripts/setup.sh

# Or edit .env file directly
nano docker/.env

# Then restart services
cd docker && docker-compose down && docker-compose up -d
\`\`\`

## 📊 Monitoring

### Health Checks
All services include health checks. Check status:
\`\`\`bash
./scripts/status.sh
\`\`\`

### Logs
View service logs:
\`\`\`bash
./scripts/logs.sh <service_name>
\`\`\`

### Resource Usage
\`\`\`bash
# Container resource usage
docker stats

# Network information
docker network ls
docker network inspect <network_name>
\`\`\`

## 🚨 Troubleshooting

### Common Issues

1. **Port Conflicts**: Change ports in \`.env\` file
2. **Permission Issues**: Ensure config files are readable
3. **Network Issues**: Check if networks exist and services are connected
4. **Authentication**: Verify MQTT and database credentials

### Reset Everything
\`\`\`bash
cd docker
docker-compose down -v
docker system prune -f
./scripts/start-dev.sh
\`\`\`

## 📁 Project Structure

\`\`\`
project/
├── docker/
│   ├── docker-compose.yml
│   ├── .env
│   ├── .env.backup
│   └── configs/
│       ├── redis/redis.conf
│       ├── mosquitto/
│       │   ├── mosquitto.conf
│       │   └── passwd
│       ├── postgres/
│       └── influxdb/
├── scripts/
│   ├── setup.sh
│   ├── start-dev.sh
│   ├── start-prod.sh
│   ├── stop.sh
│   ├── logs.sh
│   └── status.sh
└── README.md
\`\`\`

---

**Security Note**: This configuration is optimized for development and testing. For production deployment, additional security measures should be implemented, including SSL/TLS certificates, stronger authentication, and network monitoring.
EOF

echo ""
echo -e "${GREEN}🎉 Docker Infrastructure Setup Complete!${NC}"
echo ""
echo -e "${BLUE}📖 Your Configuration:${NC}"
echo -e "  ${CYAN}Project Name:${NC} $PROJECT_NAME"
echo -e "  ${CYAN}Timezone:${NC} $TIMEZONE"
echo -e "  ${CYAN}Redis Port:${NC} $REDIS_PORT"
echo -e "  ${CYAN}MQTT Port:${NC} $MQTT_PORT (WebSocket: $MQTT_WS_PORT)"
echo -e "  ${CYAN}MQTT User:${NC} $MQTT_USERNAME"
echo -e "  ${CYAN}Database Port:${NC} $POSTGRES_PORT"
echo -e "  ${CYAN}InfluxDB Port:${NC} $INFLUXDB_PORT"
echo ""
echo -e "${YELLOW}🚀 Quick Start Commands:${NC}"
echo "  ${GREEN}Development:${NC} ./scripts/start-dev.sh"
echo "  ${GREEN}Production:${NC} ./scripts/start-prod.sh"
echo "  ${GREEN}Status:${NC} ./scripts/status.sh"
echo "  ${GREEN}Logs:${NC} ./scripts/logs.sh <service>"
echo "  ${GREEN}Stop:${NC} ./scripts/stop.sh"
echo ""
echo -e "${CYAN}🔗 Network Architecture:${NC}"
echo "  - Frontend (172.20.0.0/24): External access"
echo "  - Backend (172.21.0.0/24): MQTT services"
echo "  - Database (172.22.0.0/24): PostgreSQL, InfluxDB (isolated)"
echo "  - Cache (172.23.0.0/24): Redis (isolated)"
echo "  - Admin (172.24.0.0/24): Management tools"
echo ""
echo -e "${CYAN}🛠️ Development tools (with --profile tools):${NC}"
echo "  - Redis Commander: http://localhost:$REDIS_COMMANDER_PORT"
echo "  - Adminer: http://localhost:$ADMINER_PORT"
echo "  - Traefik Dashboard: http://localhost:8090"
echo ""
echo -e "${CYAN}🔐 Security Features:${NC}"
echo "  - Isolated database networks"
echo "  - MQTT authentication required"
echo "  - Traefik reverse proxy"
echo "  - Health checks on all services"
echo ""
echo -e "${GREEN}📚 See README.md for detailed usage and examples!${NC}"
echo -e "${YELLOW}💾 Configuration backed up to docker/.env.backup${NC}"
echo -e "${BLUE}🔄 To reconfigure later, run this script again${NC}"
