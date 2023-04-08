#!/bin/sh

set -e

# if cert and key not found then generate them.
if [[ ! -e /etc/squid/certs/cert.pem ]] && [[ ! -e /etc/squid/certs/key.pem ]]
then
    openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout /etc/squid/certs/key.pem -out /etc/squid/certs/cert.pem -subj "/CN=localhost"
fi

# permit squid to write to mounted cache dir
chown -R squid:squid /var/cache/squid/

# create cache dir
squid -Nz

# avoid crash: https://serverfault.com/a/927172
rm -rfv /var/lib/ssl_db/
/usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB
chown -R squid.squid /var/lib/ssl_db

exec squid -NYCd 1
