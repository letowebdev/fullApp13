#!/bin/sh

# Initialize PostgreSQL if not already done
if [ ! -f "/var/lib/postgresql/data/PG_VERSION" ]; then
    su postgres -c 'initdb -D /var/lib/postgresql/data'
    # Configure PostgreSQL to listen on all interfaces
    echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf
    # Allow connections from any IP
    echo "host all all 0.0.0.0/0 md5" >> /var/lib/postgresql/data/pg_hba.conf
fi

# Start PostgreSQL
su postgres -c 'pg_ctl start -D /var/lib/postgresql/data'

# Wait for PostgreSQL to start
until su postgres -c 'pg_isready'; do
    echo "Waiting for PostgreSQL to start..."
    sleep 1
done

# Create user and database if they don't exist
su postgres -c "psql -c \"CREATE USER ${POSTGRES_USER:-app} WITH PASSWORD '${POSTGRES_PASSWORD:-check24}';\""
su postgres -c "psql -c \"CREATE DATABASE ${POSTGRES_DB:-app} OWNER ${POSTGRES_USER:-app};\""
su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB:-app} TO ${POSTGRES_USER:-app};\""

# Keep PostgreSQL running
su postgres -c 'postgres -D /var/lib/postgresql/data'