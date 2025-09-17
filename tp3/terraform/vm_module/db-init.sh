#!/bin/bash
set -ex
set -o pipefail
export DEBIAN_FRONTEND=noninteractive

# Install PostgreSQL and curl
apt-get update
apt-get install -y postgresql postgresql-contrib curl

# Download and install the latest Azure CLI
echo "Downloading and installing Azure CLI..."
curl -L https://aka.ms/InstallAzureCLIDeb -o install-azure-cli.sh
chmod +x install-azure-cli.sh
./install-azure-cli.sh

# Verify the CLI installation
echo "Verifying az command..."
which az
az --version

# Fetch DB credentials from Key Vault
# Retry login, as it can take a moment for the VM's managed identity to be granted access
for i in {1..10}; do
  if az login --identity; then
    echo "az login successful on attempt $i"
    break
  fi
  echo "Attempt $i: az login failed, retrying in 30 seconds..."
  sleep 30
done

DB_USER=""
DB_PASSWORD=""

# Retry fetching secrets, as access policy might take a moment to apply
for i in {1..5}; do
  if user=$(az keyvault secret show --vault-name "${key_vault_name}" --name "${db_user_secret_name}" --query value -o tsv); then
    DB_USER=$user
  fi
  if pass=$(az keyvault secret show --vault-name "${key_vault_name}" --name "${db_password_secret_name}" --query value -o tsv); then
    DB_PASSWORD=$pass
  fi
  if [ -n "$${DB_USER}" ] && [ -n "$${DB_PASSWORD}" ]; then
    break
  fi
  echo "Attempt $i: Failed to fetch DB secrets, retrying in 15 seconds..."
  sleep 15
done

if [ -z "$${DB_USER}" ] || [ -z "$${DB_PASSWORD}" ]; then echo "Could not fetch DB secrets from Key Vault. Exiting." >&2; exit 1; fi

# Configure PostgreSQL to listen on all interfaces (or a specific private IP)
# Use a wildcard to avoid issues with different PostgreSQL versions
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf

# Allow connections only from the website VM's private IP for better security
echo "host all all ${website_ip}/32 md5" >> /etc/postgresql/*/main/pg_hba.conf

# Restart PostgreSQL service
systemctl restart postgresql

# Create a new user and database for Django
# Use the credentials fetched from Key Vault
DB_PASSWORD_ESCAPED=$${DB_PASSWORD//\'/\'\'}
CREATE_USER_CMD="CREATE USER \"$${DB_USER}\" WITH PASSWORD '$${DB_PASSWORD_ESCAPED}';"
CREATE_DB_CMD="CREATE DATABASE pmgndb OWNER \"$${DB_USER}\";"
sudo -u postgres psql -c "$${CREATE_USER_CMD}"
sudo -u postgres psql -c "$${CREATE_DB_CMD}"