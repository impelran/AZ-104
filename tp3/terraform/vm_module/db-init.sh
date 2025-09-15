# Install PostgreSQL
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib

# Configure PostgreSQL to listen on all interfaces (or a specific private IP)
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf

# Allow connections from the entire subnet
sudo sed -i "\$a\host all all 10.0.1.0/24 trust" /etc/postgresql/12/main/pg_hba.conf

# Restart PostgreSQL service
sudo systemctl restart postgresql

# Create a new user and database for Django
sudo -u postgres psql -c "CREATE USER romain WITH PASSWORD 'password_for_django';"
sudo -u postgres createdb -O romain pmgndb