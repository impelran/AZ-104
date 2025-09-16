#!/bin/bash
set -ex

# Install Nginx
apt-get update
apt-get install -y nginx

# Configure Nginx to act as a reverse proxy
tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80;
    server_name ${public_dns};

    location / {
        proxy_pass http://${website_ip}:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Restart Nginx
systemctl restart nginx
systemctl enable nginx