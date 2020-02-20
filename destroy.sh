#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
magenta=`tput setaf 5`
bold=$(tput bold)
reset=`tput sgr0`

export TF_WARN_OUTPUT_ERRORS=1

terraform_destroy() {
  echo "${bold}${magenta}destroying lab...${reset}"
  terraform init && terraform destroy -auto-approve
  if [ $? -eq 0 ]; then
    echo "${bold}${green}lab destroyed!${reset}"
  else
    echo "${bold}${red}error!${reset}"
  fi
}

time terraform_destroy
