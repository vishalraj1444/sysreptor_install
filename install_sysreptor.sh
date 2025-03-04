#!/bin/bash
set -e

# ----------------------[ ANSI COLOR CODES ]----------------------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"
# ---------------------------------------------------------------

# --- 0. Ensure script is run as root ---
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root. Please run with sudo.${RESET}"
    exit 1
fi

# --- 0.1. Remove any 'wheezy' references to avoid apt errors ---
if grep -i 'wheezy' /etc/apt/sources.list  2>/dev/null; then
    echo -e "${YELLOW}Detected 'wheezy' references in sources. Commenting them out...${RESET}"
    sed -i '/wheezy/s/^/#/' /etc/apt/sources.list  2>/dev/null || true
fi

# --- 1. Define installation directory and create it ---
INSTALL_DIR="/opt/sysreptor"
echo -e "${CYAN}Installing SysReptor in ${INSTALL_DIR}...${RESET}"
mkdir -p "${INSTALL_DIR}"
if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER":"$SUDO_USER" "${INSTALL_DIR}"
fi
cd "${INSTALL_DIR}"

# --- 2. Update packages and install prerequisites ---
echo -e "${CYAN}Updating packages and installing prerequisites...${RESET}"
apt-get update
# apt-get upgrade -y   # Uncomment if you want to upgrade all packages
apt-get install -y \
    sed \
    curl \
    openssl \
    uuid-runtime \
    coreutils \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    gnupg \
    xclip

# --- 3. Install Docker if not already installed (from Kali repo) ---
if ! command -v docker &>/dev/null; then
    echo -e "${YELLOW}Docker not found. Installing Docker from Kali's repository...${RESET}"
    apt-get install -y docker.io
else
    echo -e "${GREEN}Docker is already installed.${RESET}"
fi

# --- 4. Manually install Docker Compose v2 plugin ---
echo "Manually installing Docker Compose v2 plugin..."
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 \
    -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# --- 5. Download and extract SysReptor setup tarball ---
echo -e "${CYAN}Downloading SysReptor setup tarball...${RESET}"
curl -s -L --output sysreptor.tar.gz \
    https://github.com/syslifters/sysreptor/releases/latest/download/setup.tar.gz

echo -e "${CYAN}Extracting SysReptor setup...${RESET}"
tar xzf sysreptor.tar.gz

# --- 6. Prepare environment file ---
cd sysreptor/deploy
if [ ! -f app.env ]; then
    echo -e "${CYAN}Creating app.env from example...${RESET}"
    cp app.env.example app.env
fi
if ! grep -q SECRET_KEY app.env; then
    echo -e "${CYAN}Generating SECRET_KEY...${RESET}"
    printf "SECRET_KEY=\"%s\"\n" "$(openssl rand -base64 64 | tr -d '\n=')" >> app.env
fi

# --- 7. Update Docker Compose configuration to expose port 1444 ---
echo -e "${CYAN}Updating port mapping in docker-compose.yml...${RESET}"
sed -i 's/127\.0\.0\.1:8000:8000/0.0.0.0:1444:8000/' sysreptor/docker-compose.yml

# --- 8. Create necessary Docker volumes ---
if ! docker volume ls | grep -q sysreptor-app-data; then
    echo -e "${CYAN}Creating Docker volume sysreptor-app-data...${RESET}"
    docker volume create sysreptor-app-data
fi
if ! docker volume ls | grep -q sysreptor-db-data; then
    echo -e "${CYAN}Creating Docker volume sysreptor-db-data...${RESET}"
    docker volume create sysreptor-db-data
fi

# --- 9. Start SysReptor containers ---
echo -e "${CYAN}Starting SysReptor containers (docker compose up -d)...${RESET}"
docker compose up -d

# --- 10. Wait for the app container to be healthy ---
echo -e "${CYAN}Waiting for the SysReptor app to become healthy...${RESET}"
while true; do
    STATUS=$(docker inspect --format '{{.State.Health.Status}}' sysreptor-app 2>/dev/null || echo "unhealthy")
    if [ "$STATUS" = "healthy" ]; then
        echo -e "${GREEN}SysReptor app is healthy.${RESET}"
        break
    else
        echo -e "${YELLOW}SysReptor app status: $STATUS. Waiting 5 seconds...${RESET}"
        sleep 5
    fi
done

# --- 11. Copy password to clipboard ---
PASSWORD="redhunter1444"
echo -e "${CYAN}Copying password '${PASSWORD}' to clipboard (xclip)...${RESET}"
echo "$PASSWORD" | xclip -selection clipboard
echo -e "${GREEN}Password '${PASSWORD}' copied to clipboard.${RESET}"

# --- 12. Create superuser interactively ---
echo -e "${CYAN}Creating superuser interactively...${RESET}"
echo -e "${YELLOW}When prompted, use the following details:
   Username: redhunter
   Email:    redhunter@example.com
   Password: (Already copied to your clipboard)
${RESET}"
docker compose run --rm app python3 manage.py createsuperuser --username redhunter

# --- 13. Final message with access URL ---
HOST_IP=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}Installation complete.${RESET}"
echo -e "${CYAN}Access SysReptor at: http://${HOST_IP}:1444/login/${RESET}"
