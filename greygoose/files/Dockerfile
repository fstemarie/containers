FROM alpine:latest

COPY entrypoint.sh /entrypoint.sh
# Install dnsmasq and the Docker CLI
RUN \
    apk add --no-cache dnsmasq openssh-client docker-cli bash; \
    mkdir -p /etc/dnsmasq.d/hosts; \
    chmod +x /entrypoint.sh; \
    mkdir -p /root/.ssh

ENTRYPOINT ["/entrypoint.sh"]