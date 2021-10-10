#!/bin/sh

# Ensure that we have the desired tree
mkdir -p /var/lib/rootca/local
chmod 700 /var/lib/rootca/local
mkdir -p /var/lib/rootca/input
mkdir -p /var/lib/rootca/output

# Generate a new root key if one hasn't been generated already
if [ ! -e /var/lib/rootca/local/rootCA.key ] ; then
    openssl genpkey -algorithm ED25519 -outform PEM -out /var/lib/rootca/local/rootCA.key
    chmod 400 /var/lib/rootca/local/rootCA.key
fi

# Generate a new root certificate if one hasn't been generated already
if [ ! -e /var/lib/rootca/local/rootCA.pem ] ; then
    openssl req -x509 -config /etc/rootca.cnf -new -nodes -sha256 -days 3650 \
        -subj "/C=US/ST=IA/O=Andne.net/CN=Andne Root CA" \
        -key /var/lib/rootca/local/rootCA.key -out /var/lib/rootca/local/rootCA.pem
    chmod 400 /var/lib/rootca/local/rootCA.pem
fi

openssl x509 -in /var/lib/rootca/local/rootCA.pem -text

while : ; do
    sleep 1
done
