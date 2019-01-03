#!/bin/bash

# Stop postgres instance and clear out PGDATA
sudo -u postgres -i bash -c 'pg_ctl -D ${PGDATA} -w stop'
rm -rf ${PGDATA}

# Create a pg pass file so pg_basebackup can send a password to the primary
cat > ~/.pgpass.conf <<EOF
*:5432:replication:${POSTGRES_USER}:${POSTGRES_PASSWORD}
EOF
chown postgres:postgres ~/.pgpass.conf
chmod 0600 ~/.pgpass.conf

# Backup replica from the primary
until PGPASSFILE=~/.pgpass.conf pg_basebackup -h ${REPLICATE_FROM} -D ${PGDATA} -U ${POSTGRES_USER} -vP -w
do
    # If docker is starting the containers simultaneously, the backup may encounter
    # the primary amidst a restart. Retry until we can make contact.
    sleep 1
    echo "Retrying backup . . ."
done

# Remove pg pass file -- it is not needed after backup is restored
# rm ~/.pgpass.conf

# Create the recovery.conf file so the backup knows to start in recovery mode
cat > ${PGDATA}/recovery.conf <<EOF
standby_mode = on
primary_conninfo = 'host=${REPLICATE_FROM} port=5432 user=${POSTGRES_USER} password=${POSTGRES_PASSWORD} application_name=${REPLICA_NAME}'
primary_slot_name = '${REPLICA_NAME}_slot'
EOF

# Ensure proper permissions on recovery.conf
chown postgres:postgres ${PGDATA}/recovery.conf
chmod 0600 ${PGDATA}/recovery.conf

sudo -u postgres -i bash -c 'pg_ctl -D ${PGDATA} -w start'

