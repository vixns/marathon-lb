FROM vixns/marathon-lb:vault-certs
RUN groupadd -g 987 runner \
&& useradd -u 987 -g 987 runner \
&& mkdir -p /var/state/haproxy /var/run/haproxy \
&& chown -R runner /marathon-lb /var/state/haproxy /var/run/haproxy

USER runner
