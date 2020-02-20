#! /bin/bash

apt-get update
apt-get install -y apache2 apache2-utils dnsutils

vm_hostname="$(curl -H "Metadata-Flavor:Google" \
http://169.254.169.254/computeMetadata/v1/instance/name)"
echo "Host Name: $vm_hostname" | tee /var/www/html/index.html
sudo sed -i "/Listen 80/c\Listen 3306" /etc/apache2/ports.conf
systemctl restart apache2

touch /tmp/dbsync
chmod a+x /tmp/dbsync
cat <<EOF > /tmp/dbsync
i=0
while [ \$i -lt 3 ]; do
  ab -n 2 -c 2 http://${remote_db_ip}/ > /dev/null 2>&1
  let i=i+1
  sleep 5
done
EOF

echo "*/5 * * * * /tmp/dbsync 2>&1 > /dev/null" > /tmp/crontab.txt
crontab /tmp/crontab.txt
