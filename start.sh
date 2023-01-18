#!/bin/sh

set -e

# permit squid to write to mounted cache dir
chown -R squid:squid /var/cache/squid/

# create cache dir
squid -Nz

# avoid crash: https://serverfault.com/a/927172
rm -rfv /var/lib/ssl_db/
/usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB
chown -R squid.squid /var/lib/ssl_db

exec squid -NYCd 1
