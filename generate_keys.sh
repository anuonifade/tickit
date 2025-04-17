#!/bin/bash

# Generate secure keys for HIPAA-compliant application
echo "Generating secure keys for HIPAA-compliant application..."

# Generate Rails master key if it doesn't exist
if [ ! -f ./tickit-api/config/master.key ]; then
  echo "Generating Rails master key..."
  cd ./tickit-api
  RAILS_ENV=development bundle exec rails credentials:edit
  cd ..
fi

# Generate Secret Key Base
SECRET_KEY_BASE=$(openssl rand -hex 64)
echo "Generated Secret Key Base"

# Generate Lockbox Master Key (for encryption)
LOCKBOX_MASTER_KEY=$(openssl rand -hex 32)
echo "Generated Lockbox Master Key"

# Generate Blind Index Master Key (for searchable encryption - requires 16 bytes)
BLIND_INDEX_MASTER_KEY=$(openssl rand -hex 16)
echo "Generated Blind Index Master Key"

# Update .env file with the generated keys
sed -i.bak "s/SECRET_KEY_BASE=.*/SECRET_KEY_BASE=$SECRET_KEY_BASE/" .env
sed -i.bak "s/LOCKBOX_MASTER_KEY=.*/LOCKBOX_MASTER_KEY=$LOCKBOX_MASTER_KEY/" .env
sed -i.bak "s/BLIND_INDEX_MASTER_KEY=.*/BLIND_INDEX_MASTER_KEY=$BLIND_INDEX_MASTER_KEY/" .env

# Remove backup file
rm .env.bak

echo "Keys have been generated and added to .env file"
echo "IMPORTANT: Keep these keys secure and never commit them to version control!"
