FROM alpine:latest

LABEL maintainer="andy@andne.net" updated="2021-10-23"

RUN apk add --no-cache openssl

COPY rootca.cnf /etc/

RUN mkdir -p /var/lib/rootca
WORKDIR /var/lib/rootca

COPY generate-*.sh /usr/bin/

COPY entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT [ "/opt/entrypoint.sh" ]
