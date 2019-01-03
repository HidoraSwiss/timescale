#!/bin/bash
# Backup replica from the primary
until PGPASSFILE=~/.pgpass.conf pg_basebackup -h ${REPLICATE_FROM} -D ${PGDATA} -U ${POSTGRES_USER} -vP -w
do
    # If docker is starting the containers simultaneously, the backup may encounter
    # the primary amidst a restart. Retry until we can make contact.
    sleep 1
    echo "Retrying backup . . ."
done
