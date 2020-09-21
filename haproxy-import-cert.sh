#!/bin/sh

FQDN="${1}"
HAPROXY_SOCKET="/var/run/haproxy/socket"
[ -n "$HAPROXY_CERTS_DIR" ] || exit 1

# Save cert to a file
cat - >  "${HAPROXY_CERTS_DIR}/${FQDN}.pem"

# TODO: Why is this needed? Seems to active the socket or something
echo "show info" | socat ${HAPROXY_SOCKET}  -

echo "new ssl cert ${HAPROXY_CERTS_DIR}/${FQDN}.pem" | socat ${HAPROXY_SOCKET} -
echo "show ssl cert" | socat ${HAPROXY_SOCKET} -
echo -e "set ssl cert ${HAPROXY_CERTS_DIR}/${FQDN}.pem <<\n$(cat ${HAPROXY_CERTS_DIR}/${FQDN}.pem)\n" | socat ${HAPROXY_SOCKET} -
echo "commit ssl cert ${HAPROXY_CERTS_DIR}/${FQDN}.pem" | socat ${HAPROXY_SOCKET} -
