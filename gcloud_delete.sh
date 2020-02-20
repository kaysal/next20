#!/bin/bash
# Author: salawu@google.com
# Purpose: Configures the base configuration for the Network Intelligence Center lab.
# Self execute: curl https://storage.googleapis.com/next20-codelab/gcloud.sh | bash

red=`tput setaf 1`
green=`tput setaf 2`
magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

gcloud_destroy() {
  echo "${bold}${green}removing project metadata for tcp proxy address...${reset}"
  gcloud -q compute project-info remove-metadata --keys lb-vip

  echo ""
  echo "${bold}${green}deleting forwarding rule...${reset}"
  gcloud -q beta compute forwarding-rules delete my-tcp-lb-ipv4-forwarding-rule --global

  echo ""
  echo "${bold}${green}deleting forwarding rule address...${reset}"
  gcloud -q compute addresses delete tcp-lb-static-ipv4 --global

  echo ""
  echo "${bold}${green}deleting tcp proxy...${reset}"
  gcloud -q compute target-tcp-proxies delete my-tcp-lb-target-proxy

  echo ""
  echo "${bold}${green}deleting backend services...${reset}"
  gcloud -q compute backend-services delete my-tcp-lb --global

  echo ""
  echo "${bold}${green}deleting health check...${reset}"
  gcloud -q compute health-checks delete my-tcp-health-check

  echo ""
  echo "${bold}${green}deleting instance groups and named ports...${reset}"
  gcloud -q compute instance-groups unmanaged delete ig-us --zone us-east4-b
  gcloud -q compute instance-groups unmanaged delete ig-eu --zone europe-west2-b

  echo ""
  echo "${bold}${green}deleting instances...${reset}"
  gcloud -q compute instances delete probe-us --zone=us-central1-b
  gcloud -q compute instances delete db-eu --zone=europe-west2-c
  gcloud -q compute instances delete db-us --zone=us-east4-c
  gcloud -q compute instances delete web-eu --zone=europe-west2-b
  gcloud -q compute instances delete web-us --zone=us-east4-b

  echo ""
  echo "${bold}${green}deleting firewall rules...${reset}"
  gcloud -q compute firewall-rules delete allow-ssh
  gcloud -q compute firewall-rules delete allow-rfc1918
  gcloud -q compute firewall-rules delete allow-health-checks
  gcloud -q compute firewall-rules delete deny-tcp

  echo ""
  echo "${bold}${green}deleting subnets...${reset}"
  gcloud -q compute networks subnets delete subnet1 --region us-east4
  gcloud -q compute networks subnets delete subnet2 --region europe-west2
  gcloud -q compute networks subnets delete subnet3 --region us-central1

  echo ""
  echo "${bold}${green}deleting vpc...${reset}"
  gcloud -q compute networks delete vpc
}

time gcloud_destroy
