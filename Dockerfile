FROM alpine:latest

LABEL maintainer="andy@andne.net" updated="2021-10-12"

RUN apk add --no-cache openssl

COPY rootca.cnf /etc/

RUN mkdir -p /var/lib/rootca
WORKDIR /var/lib/rootca

COPY entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT [ "/opt/entrypoint.sh" ]
