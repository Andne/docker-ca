#!/bin/sh

function main()
{
    local DN="$1"; shift
    local email="$1"; shift

    export subjectAltName="email:${email}"

    mkdir -m 2755 -p /var/lib/rootca/output/${email}

    # Generate a key and signing request
    openssl genpkey -algorithm ED25519 -outform PEM \
        -out /var/lib/rootca/output/${email}/${email}.key
    openssl req -config /etc/rootca.cnf -new -subj "${DN}" \
        -key /var/lib/rootca/output/${email}/${email}.key \
        -out /var/lib/rootca/input/${email}.csr

    openssl req -text -noout -verify -in /var/lib/rootca/input/${email}.csr

    # Randomize a serial number for the new certificate
    openssl rand -hex 19 > /var/lib/rootca/serial
    openssl ca -config /etc/rootca.cnf -days 375 -extensions usr_cert -notext \
        -in /var/lib/rootca/input/${email}.csr \
        -out /var/lib/rootca/output/${email}/${email}.pem

    openssl verify -CAfile /var/lib/rootca/output/rootCA.pem \
        /var/lib/rootca/output/${email}/${email}.pem
    openssl x509 -in /var/lib/rootca/output/${email}/${email}.pem -text

    # Make sure the key can be read/deleted from outside the container
    chmod -R g+rw /var/lib/rootca/output/${email}
}

main "$@"
