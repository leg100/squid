FROM alpine:3.18

RUN apk add --no-cache squid openssl

# permit squid to write to stdout
RUN addgroup squid tty

COPY start.sh /usr/local/bin/
COPY squid.conf /etc/squid/squid.conf

EXPOSE 3128

ENTRYPOINT ["/usr/local/bin/start.sh"]
