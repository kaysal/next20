#! /bin/bash

apt-get update
apt-get install -y apache2 apache2-utils dnsutils

vm_hostname="$(curl -H "Metadata-Flavor:Google" \
http://169.254.169.254/computeMetadata/v1/instance/name)"
echo "Host Name: $vm_hostname" | tee /var/www/html/index.html
sudo sed -i "/Listen 80/c\Listen 3306" /etc/apache2/ports.conf
systemctl restart apache2
