#!/bin/bash
set -ex

# Install Nginx and OpenSSL
apt-get update
apt-get install -y nginx openssl

# Create a self-signed SSL certificate if it doesn't exist
if [ ! -f /etc/ssl/certs/django-selfsigned.pem ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/django-selfsigned.key \
    -out /etc/ssl/certs/django-selfsigned.pem \
    -subj "/CN=$${public_dns}"
fi

# Configure Nginx as a reverse proxy on HTTP and HTTPS
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

server {
    listen 443 ssl;
    server_name ${public_dns};

    ssl_certificate     /etc/ssl/certs/django-selfsigned.pem;
    ssl_certificate_key /etc/ssl/private/django-selfsigned.key;

    location / {
        proxy_pass http://${website_ip}:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

systemctl restart nginx
systemctl enable nginx