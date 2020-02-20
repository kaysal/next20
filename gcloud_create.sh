#!/bin/bash
# Author: salawu@google.com
# Purpose: Configures the base configuration for the Network Intelligence Center lab.
# Self execute: curl https://storage.googleapis.com/next20-codelab/gcloud.sh | bash

red=`tput setaf 1`
green=`tput setaf 2`
magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

gcloud_deploy() {
  echo ""
  echo "${bold}${green}creating vpc...${reset}"

  gcloud -q compute networks create vpc \
  --subnet-mode custom

  echo ""
  echo "${bold}${green}creating subnets...${reset}"

  gcloud -q compute networks subnets create subnet1 \
  --network vpc \
  --range 10.1.1.0/24 \
  --region us-east4

  gcloud -q compute networks subnets create subnet2 \
  --network vpc \
  --range 10.1.2.0/24 \
  --region europe-west2

  gcloud -q compute networks subnets create subnet3 \
  --network vpc \
  --range 10.1.3.0/24 \
  --region us-central1

  echo ""
  echo "${bold}${green}creating firewall rules...${reset}"

  gcloud -q compute firewall-rules create allow-ssh \
  --network vpc \
  --allow tcp:22 \
  --source-ranges 0.0.0.0/0

  gcloud -q compute firewall-rules create allow-rfc1918 \
  --network vpc \
  --allow all \
  --source-ranges 10.0.0.0/8

  gcloud -q compute firewall-rules create allow-health-checks \
  --network vpc \
  --allow tcp:110 \
  --target-tags allow-hc \
  --source-ranges 130.211.0.0/22,35.191.0.0/16

  gcloud -q compute firewall-rules create deny-tcp \
  --network vpc \
  --action deny \
  --rules tcp \
  --target-tags db-tier \
  --source-ranges 10.1.1.0/24

  echo ""
  echo "${bold}${green}creating web server instances...${reset}"

  gcloud -q compute instances create web-us \
  --zone=us-east4-b \
  --machine-type=n1-standard-2\
  --tags=allow-hc \
  --image-family=debian-9 \
  --image-project=debian-cloud \
  --subnet=subnet1 \
  --metadata startup-script='#! /bin/bash

  apt-get update
  apt-get install apache2 apache2-utils -y

  vm_hostname="$(curl -H "Metadata-Flavor:Google" \
  http://169.254.169.254/computeMetadata/v1/instance/name)"
  echo "Host Name: $vm_hostname" | tee /var/www/html/index.html
  sudo sed -i "/Listen 80/c\Listen 110" /etc/apache2/ports.conf
  systemctl restart apache2

  touch /tmp/probez
  chmod a+x /tmp/probez
  cat <<EOF > /tmp/probez
  i=0
  while [ \$i -lt 3 ]; do
    ab -n 2 -c 2 http://10.1.1.100:3306/ > /dev/null 2>&1
    let i=i+1
    sleep 5
  done
  EOF

  echo "*/5 * * * * /tmp/probez 2>&1 > /dev/null" > /tmp/crontab.txt
  crontab /tmp/crontab.txt'

  gcloud -q compute instances create web-eu \
  --zone=europe-west2-b \
  --machine-type=n1-standard-2\
  --tags=allow-hc \
  --image-family=debian-9 \
  --image-project=debian-cloud \
  --subnet=subnet2 \
  --metadata startup-script='#! /bin/bash

  apt-get update
  apt-get install apache2 apache2-utils -y

  vm_hostname="$(curl -H "Metadata-Flavor:Google" \
  http://169.254.169.254/computeMetadata/v1/instance/name)"
  echo "Host Name: $vm_hostname" | tee /var/www/html/index.html
  sudo sed -i "/Listen 80/c\Listen 110" /etc/apache2/ports.conf
  systemctl restart apache2

  touch /tmp/probez
  chmod a+x /tmp/probez
  cat <<EOF > /tmp/probez
  i=0
  while [ \$i -lt 3 ]; do
    ab -n 2 -c 2 http://10.1.2.100:3306/ > /dev/null 2>&1
    let i=i+1
    sleep 5
  done
  EOF

  echo "*/5 * * * * /tmp/probez 2>&1 > /dev/null" > /tmp/crontab.txt
  crontab /tmp/crontab.txt'

  echo ""
  echo "${bold}${green}creating db server instances...${reset}"

  gcloud -q compute instances create db-us \
  --zone=us-east4-c \
  --machine-type=n1-standard-2\
  --tags=db-tier \
  --image-family=debian-9 \
  --image-project=debian-cloud \
  --subnet=subnet1 \
  --private-network-ip 10.1.1.100 \
  --metadata startup-script='#! /bin/bash

  apt-get update
  apt-get install -y apache2 apache2-utils dnsutils

  vm_hostname="$(curl -H "Metadata-Flavor:Google" \
  http://169.254.169.254/computeMetadata/v1/instance/name)"
  echo "Host Name: $vm_hostname" | tee /var/www/html/index.html
  sudo sed -i "/Listen 80/c\Listen 3306" /etc/apache2/ports.conf
  systemctl restart apache2

  touch /tmp/probez
  chmod a+x /tmp/probez
  cat <<EOF > /tmp/probez
  i=0
  while [ \$i -lt 3 ]; do
    ab -n 2 -c 2 http://10.1.2.100:3306/ > /dev/null 2>&1
    let i=i+1
    sleep 5
  done
  EOF

  echo "*/5 * * * * /tmp/probez 2>&1 > /dev/null" > /tmp/crontab.txt
  crontab /tmp/crontab.txt'

  gcloud -q compute instances create db-eu \
  --zone=europe-west2-c \
  --machine-type=n1-standard-2\
  --tags=db-tier \
  --image-family=debian-9 \
  --image-project=debian-cloud \
  --subnet=subnet2 \
  --private-network-ip 10.1.2.100 \
  --metadata startup-script='#! /bin/bash

  apt-get update
  apt-get install -y apache2 apache2-utils dnsutils

  vm_hostname="$(curl -H "Metadata-Flavor:Google" \
  http://169.254.169.254/computeMetadata/v1/instance/name)"
  echo "Host Name: $vm_hostname" | tee /var/www/html/index.html
  sudo sed -i "/Listen 80/c\Listen 3306" /etc/apache2/ports.conf
  systemctl restart apache2

  touch /tmp/probez
  chmod a+x /tmp/probez
  cat <<EOF > /tmp/probez
  i=0
  while [ \$i -lt 3 ]; do
    ab -n 2 -c 2 http://10.1.1.100:3306/ > /dev/null 2>&1
    let i=i+1
    sleep 5
  done
  EOF

  echo "*/5 * * * * /tmp/probez 2>&1 > /dev/null" > /tmp/crontab.txt
  crontab /tmp/crontab.txt'

  echo ""
  echo "${bold}${green}creating instance groups and named ports...${reset}"

  gcloud -q compute instance-groups unmanaged create ig-us \
   --zone us-east4-b

  gcloud -q compute instance-groups set-named-ports ig-us \
  --named-ports tcp110:110 \
  --zone us-east4-b

  gcloud -q compute instance-groups unmanaged create ig-eu \
  --zone europe-west2-b

  gcloud -q compute instance-groups set-named-ports ig-eu \
  --named-ports tcp110:110 \
  --zone europe-west2-b

  gcloud -q compute instance-groups unmanaged add-instances ig-us \
  --instances web-us \
  --zone us-east4-b

  gcloud -q compute instance-groups unmanaged add-instances ig-eu \
  --instances web-eu \
  --zone europe-west2-b

  echo ""
  echo "${bold}${green}creating health check...${reset}"

  gcloud -q compute health-checks create tcp my-tcp-health-check --port 110

  echo ""
  echo "${bold}${green}creating backend services...${reset}"

  gcloud -q compute backend-services create my-tcp-lb \
  --global \
  --protocol TCP \
  --health-checks my-tcp-health-check \
  --timeout 5m \
  --port-name tcp110

  echo ""
  echo "${bold}${green}adding instance groups to backend service...${reset}"

  gcloud -q compute backend-services add-backend my-tcp-lb \
  --global \
  --instance-group ig-us \
  --instance-group-zone us-east4-b \
  --balancing-mode UTILIZATION \
  --max-utilization 0.8

  gcloud -q compute backend-services add-backend my-tcp-lb \
  --global \
  --instance-group ig-eu \
  --instance-group-zone europe-west2-b \
  --balancing-mode UTILIZATION \
  --max-utilization 0.8

  echo ""
  echo "${bold}${green}creating tcp proxy...${reset}"

  gcloud -q compute target-tcp-proxies create my-tcp-lb-target-proxy \
  --backend-service my-tcp-lb \
  --proxy-header NONE

  echo ""
  echo "${bold}${green}reserving forwarding rule address...${reset}"

  gcloud -q compute addresses create tcp-lb-static-ipv4 \
  --ip-version=IPV4 \
  --global

  echo ""
  echo "${bold}${green}creating forwarding rule...${reset}"

  export LB_STATIC_IPV4=`gcloud compute addresses describe tcp-lb-static-ipv4 \
  --format="value(address)" --global`

  gcloud -q beta compute forwarding-rules create my-tcp-lb-ipv4-forwarding-rule \
  --global \
  --target-tcp-proxy my-tcp-lb-target-proxy \
  --address ${LB_STATIC_IPV4} \
  --ports 110

  echo ""
  echo "${bold}${green}creating project metadata to store tcp proxy address...${reset}"

  gcloud -q compute project-info add-metadata \
  --metadata lb-vip=$LB_STATIC_IPV4

  echo ""
  echo "${bold}${green}creating a probe instance...${reset}"

  gcloud -q compute instances create probe-us \
  --zone=us-central1-b \
  --machine-type=n1-standard-2\
  --image-family=debian-9 \
  --image-project=debian-cloud \
  --subnet=subnet3 \
  --private-network-ip 10.1.3.100 \
  --metadata=startup-script='#! /bin/bash

  apt-get update
  apt-get install -y apache2-utils

  lb_vip="$(curl -H "Metadata-Flavor: Google" \
  http://169.254.169.254/computeMetadata/v1/project/attributes/lb-vip)"

  touch /tmp/probez
  chmod a+x /tmp/probez
  cat <<EOF > /tmp/probez
  i=0
  while [ \$i -lt 4 ]; do
    ab -n 2 -c 2 http://${lb_vip}:110/ > /dev/null 2>&1
    let i=i+1
    sleep 10
  done
  EOF

  echo "*/5 * * * * /tmp/probez 2>&1 > /dev/null" > /tmp/crontab.txt
  crontab /tmp/crontab.txt'
}

time gcloud_deploy
