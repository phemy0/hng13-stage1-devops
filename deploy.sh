#!/usr/bin/env bash
# ============================================================
# Automated Dockerized App Deployment Script (deploy.sh)
# ============================================================
# Author: Phemy Dev
# Description: Automates setup, deployment, and configuration
#              of a Dockerized app on a remote ubuntu Linux server.
# ============================================================

set -euo pipefail
LOG_FILE="deploy_$(date +%Y%m%d_%H%M%S).log"

# === Colors ===
GREEN="\e[32m"; RED="\e[31m"; YELLOW="\e[33m"; NC="\e[0m"

# === Logging ===
log() { echo -e "${GREEN}[✔]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[✖]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }

# === 1. Collect user input ===
collect_input() {
  echo "===== Deployment Configuration ====="
  read -rp "Enter GitHub repository URL (https://...): " REPO_URL
  read -rp "Enter your Personal Access Token (PAT): " PAT
  read -rp "Enter branch name [default: main]: " BRANCH
  BRANCH=${BRANCH:-main}
  read -rp "Enter remote server username: " SSH_USER
  read -rp "Enter remote server IP address: " SERVER_IP
  read -rp "Enter SSH key path (e.g. ~/.ssh/id_rsa): " SSH_KEY
  read -rp "Enter application internal port (container port): " APP_PORT
}

# === 2. Clone repository ===
clone_repo() {
  log "Cloning repository..."
  REPO_DIR=$(basename "$REPO_URL" .git)

  if [ -d "$REPO_DIR" ]; then
    warn "Repository already exists locally. Pulling latest changes..."
    cd "$REPO_DIR" && git pull && cd ..
  else
    git clone "https://${PAT}@${REPO_URL#https://}" || error "Failed to clone repo"
  fi

  cd "$REPO_DIR" || error "Failed to enter project directory"
  git checkout "$BRANCH"
  cd ..
  log "Repository ready: $REPO_DIR"
}

# === 3. Verify Docker configuration files ===
verify_docker_files() {
  cd "$REPO_DIR"
  if [[ -f "docker-compose.yml" || -f "Dockerfile" ]]; then
    log "Docker configuration found."
  else
    error "No Dockerfile or docker-compose.yml found in project!"
  fi
  cd ..
}

# === 4. Test SSH connection ===
test_ssh_connection() {
  log "Testing SSH connection to ${SSH_USER}@${SERVER_IP}..."
  if ssh -i "$SSH_KEY" -o BatchMode=yes -o ConnectTimeout=5 "${SSH_USER}@${SERVER_IP}" "echo connected" &>/dev/null; then
    log "SSH connection successful."
  else
    error "SSH connection failed. Check your credentials or key path."
  fi
}

# === 5. Prepare remote environment ===
remote_setup() {
  log "Preparing remote environment..."
  ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" bash -s <<'EOF'
    set -e
    sudo apt update -y
    sudo apt install -y docker.io docker-compose nginx
    sudo systemctl enable docker --now
    sudo systemctl enable nginx --now
    sudo usermod -aG docker $USER || true
    echo "Remote environment ready."
EOF
  log "Remote environment setup complete."
}

# === 6. Transfer project files ===
transfer_files() {
  log "Transferring project files..."
  scp -i "$SSH_KEY" -r "./$REPO_DIR" "${SSH_USER}@${SERVER_IP}:/home/${SSH_USER}/" || error "File transfer failed."
  log "Files transferred successfully."
}

# === 7. Deploy Docker container remotely ===
deploy_app() {
  log "Deploying Dockerized app remotely..."
  ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" bash -s <<EOF
    set -e
    cd /home/${SSH_USER}/${REPO_DIR}
    if [ -f docker-compose.yml ]; then
      sudo docker-compose down || true
      sudo docker-compose up -d --build
    elif [ -f Dockerfile ]; then
      sudo docker stop app_container 2>/dev/null || true
      sudo docker rm app_container 2>/dev/null || true
      sudo docker build -t myapp:latest .
      sudo docker run -d --name app_container -p ${APP_PORT}:${APP_PORT} myapp:latest
    fi
EOF
  log "Application deployed successfully."
}

# === 8. Configure Nginx reverse proxy ===
configure_nginx() {
  log "Configuring Nginx reverse proxy..."
  ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" bash -s <<EOF
    sudo tee /etc/nginx/sites-available/myapp.conf > /dev/null <<'NGINXCONF'
server {
    listen 80;
    server_name ${SERVER_IP};

    location / {
        proxy_pass http://localhost:${APP_PORT};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINXCONF

    sudo ln -sf /etc/nginx/sites-available/myapp.conf /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx
EOF
  log "✅ Nginx configured successfully and reloaded."
}

# === 9. Validate deployment ===
validate_deploy() {
  log "Validating deployment..."
  
  ssh -i "$SSH_KEY" "${SSH_USER}@${SERVER_IP}" bash -s <<EOF
    echo "Checking Docker and Nginx services..."
    sudo systemctl status docker --no-pager || echo "⚠️ Docker might not be running!"
    sudo docker ps || echo "⚠️ No active containers!"
    sudo systemctl status nginx --no-pager || echo "⚠️ Nginx might not be running!"
    echo "Testing local connectivity..."
    curl -I http://localhost || echo "App not reachable locally!"
EOF

  log "Validation complete ✅"
  echo ""
  echo "🎉 Your app should now be live!"
  echo "🌍 Access it in your browser at: http://${SERVER_IP}/demo"
  echo ""
}


# === MAIN FUNCTION ===
main() {
  collect_input
  clone_repo
  verify_docker_files
  test_ssh_connection
  remote_setup
  transfer_files
  deploy_app
  configure_nginx
  validate_deploy
  log "Deployment completed successfully ✅"
}

main "$@"

