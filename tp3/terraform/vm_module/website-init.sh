#!/bin/bash
set -ex
set -o pipefail

# Install dependencies as root
export DEBIAN_FRONTEND=noninteractive
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

if [ -z "$SECRET_KEY" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
  echo "Could not fetch secrets from Key Vault after multiple retries. Exiting." >&2
  exit 1
fi

DB_URL_STRING="DATABASE_URL=postgres://$DB_USER:$DB_PASSWORD@${db_ip}:5432/pmgndb"
mkdir -p /etc/django
echo "SECRET_KEY='$SECRET_KEY'" > /etc/django/environment
echo "DEBUG=True" >> /etc/django/environment
echo "$
" >> /etc/django/environment
echo "ALLOWED_HOSTS=${allowed_hosts}" >> /etc/django/environment
chown ${admin_username}:${admin_username} /etc/django/environment
chmod 600 /etc/django/environment

# Install the Git repository
sudo git clone https://github.com/PMGN-org/PMGN_Website.git
cd PMGN_Website
sudo python3 -m venv venv
source venv/bin/activate
sudo pip install -r requirements.txt

# Start Gunicorn
cd website
DATABASE_URL='postgres://NK0NfF63SPlm:3Ijf%LHl)N{Hedl4{)t{RFJ&@10.0.1.5:5432/pmgndb' python manage.py migrate
DATABASE_URL='postgres://NK0NfF63SPlm:3Ijf%LHl)N{Hedl4{)t{RFJ&@10.0.1.5:5432/pmgndb' python manage.py collectstatic
SECURE_SSL_REDIRECT=False ALLOWED_HOSTS=tp3-proxy-vm.francecentral.cloudapp.azure.com,20.19.169.27,localhost,127.0.0.1,10.0.1.6 DATABASE_URL='postgres://NK0NfF63SPlm:3Ijf%LHl)N{Hedl4{)t{RFJ&@10.0.1.5:5432/pmgndb' DEBUG=True SECRET_KEY='L)9SHCvpWL_[VncW>8z<lx3FV=LGh7tiYrFPsZ]nVvEp_ervK8' gunicorn --chdir website --workers 5 --worker-class gevent website.wsgi:application -b 10.0.1.6:8000