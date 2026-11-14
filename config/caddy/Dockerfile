FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-l4 \
    --with github.com/mholt/caddy-events-exec

FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY deploy-proxy-cert.sh /usr/local/bin/deploy-proxy-cert.sh

RUN chmod 0755 /usr/local/bin/deploy-proxy-cert.sh