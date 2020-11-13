#!/bin/bash

oops () {
	echo "Error: $1"
	exit 1
}

domain="$1"

[ -n "$VAULT_ADDR" ] || oops "VAULT_ADDR required"
[ -n "$VAULT_PREFIX" ] || oops "VAULT_PREFIX required"

VAULT_CMD=$(command -v vault)
[ $? -eq 0 ] || oops "cannot find vault binary"

# import-cert fqdn "key" "cert"
import_cert () {
sv status /marathon-lb/service/haproxy 2>&1 > /dev/null
if [ $? -eq 0 ]
then
	echo -e "${2}\n${3}\n" | /marathon-lb/haproxy-import-cert.sh "$1"
else
	echo -e "${2}\n${3}\n" > "${HAPROXY_CERTS_DIR}/${1}.pem"
fi
}

# approle auth if VAULT_ROLE_ID exists
if [ -n "$VAULT_ROLE_ID" ]; then
	VAULT_TOKEN=$(vault write -field=token auth/approle/login \
		role_id="$VAULT_ROLE_ID" secret_id="$VAULT_ROLE_SECRET")
			if [ ! $? ]; then
				oops "cannot login to vault approle ${VAULT_ROLE_ID}!"
			fi
			export VAULT_TOKEN
fi

[ -n "$VAULT_TOKEN" ] || oops "no vault token"

if [ -z "$domain" ]
then
# iterate domains and import them
for domain in $($VAULT_CMD list -format=yaml ${VAULT_PREFIX} | awk '{print $2}' | tr -d "'")
do
	import_cert \
		"${domain}" \
		"$($VAULT_CMD read -field=key "${VAULT_PREFIX}/${domain}")" \
		"$($VAULT_CMD read -field=cert "${VAULT_PREFIX}/${domain}")"
	done
else
	import_cert \
		"${domain}" \
		"$($VAULT_CMD read -field=key "${VAULT_PREFIX}/${domain}")" \
		"$($VAULT_CMD read -field=cert "${VAULT_PREFIX}/${domain}")"
fi
