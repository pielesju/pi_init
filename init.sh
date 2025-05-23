#!/bin/bash

# print function for headlines
function pretty_print {
  echo "=================================================="
  echo " $1"
  echo "=================================================="
}

# check if script is run as root (uid 0)
function check_if_root {
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root. Please use: sudo $0" 1>&2
        exit 1
    fi
}

function install_dependencies {
    pretty_print "installing required packages..."

    apt update
    apt install -y git \
	           software-properties-common \
	           python3 \
	           python3-pip \
	           ansible

}

function clone_git_repo {
    pretty_print "clone git repository..."
    
    if [[ ! -d pi_init ]]; then
        git clone https://github.com/pielesju/pi_init.git
    else
        pushd pi_init &>/dev/null
        git pull
        popd &>/dev/null
    fi
}

function run_playbook {
    pushd pi_init &>/dev/null
    ansible-playbook -i localhost, --connection=local playbooks/pi.yml
    popd &>/dev/null
}

function main {
    pretty_print "Raspberry Pi Init"
    check_if_root
    install_dependencies
    clone_git_repo
    run_playbook
}

mkdir -p logs
timestamp=$(date +"%Y-%m-%d")
logfile="logs/pi_init_${timestamp}.log"
main | tee -a $logfile
