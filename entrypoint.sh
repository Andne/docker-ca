#!/bin/sh

# Ensure that we have the desired tree
mkdir -p /var/lib/rootca/local
chmod 700 /var/lib/rootca/local
mkdir -p /var/lib/rootca/input
mkdir -p /var/lib/rootca/output

touch /var/lib/rootca/index.txt

new_files_generated=no

# Either try to import or generate a new root key if one hasn't been generated already
if [ ! -e /var/lib/rootca/local/rootCA.key ] ; then
    if [ -e /var/lib/rootca/output/Andne-Root-Cert.tar ] ; then
        echo "Restoring root cert from bundle"
        tar xf /var/lib/rootca/output/Andne-Root-Cert.tar -C /var/lib/rootca/local
    else
        echo "No root key found, generating new root key"
        openssl genpkey -algorithm ED25519 -outform PEM -out /var/lib/rootca/local/rootCA.key
        chmod 400 /var/lib/rootca/local/rootCA.key

        new_files_generated=yes
    fi
fi

# Generate a new root certificate if one hasn't been generated already
if [ ! -e /var/lib/rootca/local/rootCA.pem ] ; then
    echo "No root certificate found, generating new root certificate"
    (
        export subjectAltName="email:certs@tridigee.com"
        openssl req -x509 -config /etc/rootca.cnf -new -nodes -sha256 -days 3650 \
            -subj "/C=US/ST=IA/O=Andne.net/CN=Andne Root CA" \
            -key /var/lib/rootca/local/rootCA.key -out /var/lib/rootca/local/rootCA.pem
    )
    chmod 444 /var/lib/rootca/local/rootCA.pem

    new_files_generated=yes
fi

# Export an archive if any new files were created
if [ "${new_files_generated}" == "yes" ] ; then
    echo "Exporting root certificate for archiving"
    tar cf /var/lib/rootca/output/Andne-Root-Cert.tar -C /var/lib/rootca/local rootCA.key rootCA.pem
    chmod 440 /var/lib/rootca/output/Andne-Root-Cert.tar
fi

# Make sure the certificate can be downloaded as wanted
cp /var/lib/rootca/local/rootCA.pem /var/lib/rootca/output/rootCA.pem

openssl x509 -in /var/lib/rootca/local/rootCA.pem -text


#############################################################
## Logic to keep running and properly shut down
#############################################################

Shutdown() {
    exit 0
}

trap Shutdown SIGINT SIGTERM

while : ; do
    sleep 1
done
