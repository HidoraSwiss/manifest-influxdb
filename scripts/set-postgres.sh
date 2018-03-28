#!/bin/bash
# Get config from GitHub
wget https://raw.githubusercontent.com/HidoraSwiss/manifest-influxdb/master/config/telegraf-postgresql.conf -O /etc/telegraf/telegraf.d/postgresql.conf
sed -i "s/PASSWORD/$1/g" /etc/telegraf/telegraf.d/postgresql.conf

# Add user Telegraf in DB
cd /var/lib/pgsql/data/
cp pg_hba.conf pg_hba.conf.telegraf
echo "host  all   all  127.0.0.1/32  trust" > pg_hba.conf
service postgresql restart
echo "create role telegraf with login password '$1' NOSUPERUSER NOCREATEDB NOCREATEROLE;"
psql -h 127.0.0.1 -U postgres -c "create role telegraf with login password '$1' NOSUPERUSER NOCREATEDB NOCREATEROLE;"
echo "host  all   telegraf  127.0.0.1/32  password" > pg_hba.conf
cat pg_hba.conf.telegraf >> pg_hba.conf
rm pg_hba.conf.telegraf
service postgresql restart

echo "DONE"
exit 0
