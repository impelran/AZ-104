#!/bin/bash
set -ex
set -o pipefail
# Install dependencies as root
export DEBIAN_FRONTEND=noninteractive
# Install dependencies
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-pip python3.8-venv git gunicorn libpq-dev curl

# Download and install the latest Azure CLI
echo "Downloading and installing Azure CLI..."
curl -L https://aka.ms/InstallAzureCLIDeb -o install-azure-cli.sh
chmod +x install-azure-cli.sh
./install-azure-cli.sh

# Verify the CLI installation
echo "Verifying az command..."
which az
az --version

# Fetch secrets from Key Vault and create an environment file for Django
for i in {1..10}; do
  if az login --identity; then
    echo "az login successful on attempt $i"
    break
  fi
  echo "Attempt $i: az login failed, retrying in 30 seconds..."
  sleep 30
done
SECRET_KEY=""
DB_USER=""
DB_PASSWORD=""
for i in {1..5}; do
  if key=$(az keyvault secret show --vault-name "${key_vault_name}" --name "${django_secret_name}" --query value -o tsv); then
    SECRET_KEY=$key
  fi
  if user=$(az keyvault secret show --vault-name "${key_vault_name}" --name "${db_user_secret_name}" --query value -o tsv); then
    DB_USER=$user
  fi
  if pass=$(az keyvault secret show --vault-name "${key_vault_name}" --name "${db_password_secret_name}" --query value -o tsv); then
    DB_PASSWORD=$pass
  fi
  if [ -n "$SECRET_KEY" ] && [ -n "$DB_USER" ] && [ -n "$DB_PASSWORD" ]; then
    break
  fi
  echo "Attempt $i: Failed to fetch secrets, retrying in 15 seconds..."
  sleep 15
done
if [ -z "$SECRET_KEY" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then echo "Could not fetch secrets from Key Vault after multiple retries. Exiting." >&2; exit 1; fi

DB_URL_STRING="DATABASE_URL=postgres://$DB_USER:$DB_PASSWORD@${db_ip}:5432/pmgndb"
mkdir -p /etc/django
echo "SECRET_KEY='$SECRET_KEY'" > /etc/django/environment
echo "DEBUG=False" >> /etc/django/environment
echo "$DB_URL_STRING" >> /etc/django/environment
echo "ALLOWED_HOSTS=${allowed_hosts}" >> /etc/django/environment
chown ${admin_username}:${admin_username} /etc/django/environment
chmod 600 /etc/django/environment

# Run user-specific setup as the admin user
su - ${admin_username} <<'EOF'
set -ex
set -a
[ -f /etc/django/environment ] && . /etc/django/environment
set +a
git clone https://github.com/PMGN-org/PMGN_Website.git
cd PMGN_Website
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 website/manage.py collectstatic --noinput
python3 website/manage.py makemigrations
python3 website/manage.py migrate
EOF

# Create and enable Gunicorn systemd service as root
tee /etc/systemd/system/gunicorn.service > /dev/null <<EOF
[Unit]
Description=Gunicorn service for PMGN Website
After=network.target
[Service]
User=${admin_username}
WorkingDirectory=/home/${admin_username}/PMGN_Website/website
EnvironmentFile=/etc/django/environment
ExecStart=/home/${admin_username}/PMGN_Website/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:8000 website.wsgi:application
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Start and enable the Gunicorn service
systemctl daemon-reload
systemctl start gunicorn
systemctl enable gunicorn
systemctl status gunicorn --no-pager
journalctl -u gunicorn --no-pager
