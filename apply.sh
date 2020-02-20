#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

export TF_WARN_OUTPUT_ERRORS=1
export GOOGLE_PROJECT=$(gcloud config get-value project)
export TF_VAR_project_id=$(gcloud config get-value project)

terraform_apply() {
  echo "${bold}${magenta}deploying lab...${reset}"
  terraform fmt && terraform init && terraform apply -auto-approve
  if [ $? -eq 0 ]; then
    echo "${bold}${green}lab deployed!${reset}"
  else
    echo "${bold}${red} error!${reset}"
  fi
}

time terraform_apply
