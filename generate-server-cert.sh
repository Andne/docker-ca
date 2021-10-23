#!/bin/sh

function main()
{
    local DN="$1"; shift
    local fqdn="$1"; shift

    if [ -z "${DN}" ] || [ -z "${fqdn}" ] ; then
        echo "Bad arguments provided, ${0} distinguished-name domain-name(s)"
        echo "DN Format: /C=<country>/ST=<state>/O=<organization>/CN=<common name"
        exit 1
    fi

    subjectAltName="DNS:${fqdn}"
    for dns_name in "$@" ; do
        subjectAltName="$subjectAltName, DNS:${dns_name}"
    done
    export subjectAltName

    mkdir -m 2755 -p /var/lib/rootca/output/${fqdn}

    # Generate a key and signing request
    openssl genpkey -algorithm ED25519 -outform PEM \
        -out /var/lib/rootca/output/${fqdn}/${fqdn}.key
    openssl req -config /etc/rootca.cnf -new -subj "${DN}" \
        -key /var/lib/rootca/output/${fqdn}/${fqdn}.key \
        -out /var/lib/rootca/input/${fqdn}.csr

    openssl req -text -noout -verify -in /var/lib/rootca/input/${fqdn}.csr

    # Randomize a serial number for the new certificate
    openssl rand -hex 19 > /var/lib/rootca/serial
    openssl ca -config /etc/rootca.cnf -days 375 -extensions server_cert -notext \
        -in /var/lib/rootca/input/${fqdn}.csr \
        -out /var/lib/rootca/output/${fqdn}/${fqdn}.pem

    # Validate that the generated certificate is good
    openssl verify -CAfile /var/lib/rootca/local/rootCA.pem \
        /var/lib/rootca/output/${fqdn}/${fqdn}.pem
    openssl x509 -in /var/lib/rootca/output/${fqdn}/${fqdn}.pem -text

    # Make sure the key can be read/deleted from outside the container
    chmod -R g+rw /var/lib/rootca/output/${fqdn}
}

main "$@"
