# Install dependencies
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3.8-venv git gunicorn libpq-dev

# Clone the repository
git clone https://github.com/PMGN-org/PMGN_Website.git

# Setup Python environment
cd PMGN_Website
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

python3 website/manage.py collectstatic --noinput
python3 website/manage.py makemigrations
python3 website/manage.py migrate

# Create a Gunicorn systemd service
sudo tee /etc/systemd/system/gunicorn.service > /dev/null <<EOF
[Unit]
Description=Gunicorn service for PMGN Website
After=network.target

[Service]
User=${admin_username}
Group=${admin_username}
WorkingDirectory=/home/${admin_username}/PMGN_Website/website
ExecStart=/home/${admin_username}/PMGN_Website/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:8000 website.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

# Start and enable the Gunicorn service
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn