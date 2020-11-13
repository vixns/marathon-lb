#!/bin/bash

FQDN="${1}"
HAPROXY_SOCKET="/var/run/haproxy/socket"
[ -n "$HAPROXY_CERTS_DIR" ] || exit 1

mkdir -p $HAPROXY_CERTS_DIR

# Save cert to a file
cat - >  "${HAPROXY_CERTS_DIR}/${FQDN}.pem"

echo "show ssl cert" | socat ${HAPROXY_SOCKET} - > /dev/null
echo "new ssl cert ${HAPROXY_CERTS_DIR}/${FQDN}.pem" | socat ${HAPROXY_SOCKET} - 2>&1 > /dev/null
echo -e "set ssl cert ${HAPROXY_CERTS_DIR}/${FQDN}.pem <<\n$(grep . "${HAPROXY_CERTS_DIR}/${FQDN}.pem")\n" | socat ${HAPROXY_SOCKET} -
echo "commit ssl cert ${HAPROXY_CERTS_DIR}/${FQDN}.pem" | socat ${HAPROXY_SOCKET} -
