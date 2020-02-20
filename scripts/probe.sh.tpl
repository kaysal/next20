#! /bin/bash

apt-get update
apt-get install -y apache2-utils

touch /tmp/probez
chmod a+x /tmp/probez
cat <<EOF > /tmp/probez
i=0
while [ \$i -lt 3 ]; do
  ab -n 2 -c 2 http://${lb_vip}:110/ > /dev/null 2>&1
  let i=i+1
  sleep 5
done
EOF

echo "*/5 * * * * /tmp/probez 2>&1 > /dev/null" > /tmp/crontab.txt
crontab /tmp/crontab.txt
