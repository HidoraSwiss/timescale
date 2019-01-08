**timescale**

*Description Timescale*

*How to install Timescale on Hidora*

1. import the manifest.jps into Hidora platform

After few minutes, you will have to continue to configure the Slave database, for that, enter these commands below : 

1. until PGPASSFILE=~/.pgpass.conf pg_basebackup -h ${REPLICATE_FROM} -D ${PGDATA} -U ${POSTGRES_USER} -vP -w; do    echo "Retrying backup ...";sleep 2; done
2. if it is ok, then : rm ~/.pgpass.conf
3. echo "standby_mode = on" > /var/lib/postgresql/data/pgdata/recovery.conf
4. echo "primary_conninfo = 'host=${REPLICATE_FROM} port=5432 user=${POSTGRES_USER} password=${POSTGRES_PASSWORD} application_name=${REPLICA_NAME}'" >>  /var/lib/postgresql/data/pgdata/recovery.conf
5. echo "primary_slot_name = '${REPLICA_NAME}_slot'" >> /var/lib/postgresql/data/pgdata/recovery.conf
6. chown -R postgres:postgres ${PGDATA}
7. chmod 0600 ${PGDATA}/recovery.conf
8. sudo -u postgres -i bash -c 'pg_ctl -D ${PGDATA} -w start'
