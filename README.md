# Squid caching proxy with SSL bumping enabled

This repo provides a Dockerfile for running [Squid](http://www.squid-cache.org/) in a docker container. It configures Squid to use [SSL bumping](https://wiki.squid-cache.org/Features/SslBump), a technique that permits Squid, among other things, to cache content for HTTPS sites. Without SSL bumping, Squid simply forwards connections without caching the content.

## Quickstart

You need a certificate authority. Here's how to generate one if you don't have one already:

```bash
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout key.pem -out ca.pem -subj "/CN=squid.local"
```

To run Squid in the container, first place the certificate authority cert and key in a directory:

```
mkdir certs
cp cert.pem key.pem certs/
```

And run the container, mounting the certs directory accordingly:

```
docker run -t -p 3128:3128 -v $PWD/certs:/etc/squid/certs leg100/squid
```

This runs the container in the foreground, listening on port 3128.

To test it is caching content, make requests in another terminal:

```
curl --cacert certs/ca.pem -x localhost:3128 https://news.ycombinator.com
```

If you make more than one request you should see the Squid logs report a cache hit the second time onwards:

```
1675241713.717     34 172.17.0.1 NONE_NONE/200 0 CONNECT news.ycombinator.com:443 - HIER_NONE/- -
1675241714.546    828 172.17.0.1 TCP_MISS/200 37150 GET https://news.ycombinator.com/ - HIER_DIRECT/209.216.230.240
text/html
1675241716.195     13 172.17.0.1 NONE_NONE/200 0 CONNECT news.ycombinator.com:443 - HIER_NONE/- -
1675241716.195      0 172.17.0.1 TCP_MEM_HIT/200 37156 GET https://news.ycombinator.com/ - HIER_NONE/- text/html
1675241717.876     11 172.17.0.1 NONE_NONE/200 0 CONNECT news.ycombinator.com:443 - HIER_NONE/- -
1675241717.877      0 172.17.0.1 TCP_MEM_HIT/200 37156 GET https://news.ycombinator.com/ - HIER_NONE/- text/html
```

### Instruct clients to trust proxy

Above we needed to explicitly instruct `curl` to trust the certificate authority. To have curl, and other software too, implicitly trust the proxy you'll need to add the certificate to your system's certificate trust store.

For example, on Ubuntu:

```bash
cp ca.pem /usr/local/share/ca-certificates/squid.crt
sudo update-ca-certificates
```

You can then run curl without the `--cacert` flag:

```
curl -x localhost:3128 https://news.ycombinator.com
```
