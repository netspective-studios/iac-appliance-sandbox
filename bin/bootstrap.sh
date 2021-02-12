#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

title() {
    local color='\033[1;37m'
    local nc='\033[0m'
    printf "\n${color}$1${nc}\n"
}

title "Install Python and Ansible"
sudo apt-get install -y software-properties-common
sudo apt-add-repository ppa:ansible/ansible -y
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install -y curl wget ansible git make python-pip

title "Install roles from Ansible Galaxy"
sudo ansible-galaxy install viasite-ansible.zsh
sudo ansible-galaxy install robertdebock.ara

# NSSA_ prefix used for all Netspective Studios Service Appliance config params
export NSSA_HOME=/etc/netspective-service-appliances

export NSSA_FF_SETUP_K8s=${NSSA_FF_SETUP_K8s:-True}  
export NSSA_FF_SETUP_NSF=${NSSA_FF_SETUP_NSF:-True}

# Before running bootstrap.sh, set the type of appliance we're creating
export NSSA_APPLIANCE=${NSSA_APPLIANCE:-engineering-sandbox}
export NSSA_APPLIANCE_CONF=${NSSA_APPLIANCE:-$NSSA_HOME/appliances/playbooks.d/$NSSA_APPLIANCE}
export NSSA_APPLIANCE_PLAYBOOKS=${NSSA_APPLIANCE:-$NSSA_HOME/appliances/playbooks.d/$NSSA_APPLIANCE}

# TODO: add validation to make sure:
#       - ${NSSA_APPLIANCE_*} series of directories exist
#       - ${NSSA_APPLIANCE_PLAYBOOKS}/ara.ansible-playbook.yml exists 
#       - ${NSSA_APPLIANCE_PLAYBOOKS}/zsh.ansible-playbook.yml exists

# NSSA_HOME/appliances contains directories which are named for the appliance's purpose
# - conf/* are either files or symlinks to NSSA_HOME/conf/* entries
# - config/config.ts is an optional TypeScript Governed Structured Data (GSD) file
# - config/config.auto.* are files generated by the optional config.ts file
# - playbooks.d/* are either files or symlinks to NSSA_HOME/playbooks/* entries

title "Download distribution into $NSSA_HOME"
sudo git clone --recurse https://github.com/netspective-studios/service-appliances $NSSA_HOME

title "Prepare appliance secrets configuration"
sudo cp $NSSA_HOME/conf/appliance.secrets-tmpl.ansible-vars.yml $NSSA_HOME/conf/appliance.secrets.ansible-vars.yml

title "Provision ARA setup playbook"
sudo ansible-playbook -i "localhost," -c local $NSSA_APPLIANCE_PLAYBOOKS/ara.ansible-playbook.yml

title "Provision ZSH setup playbook for $(whoami)"
sudo ansible-playbook -i "localhost," -c local $NSSA_APPLIANCE_PLAYBOOKS/zsh.ansible-playbook.yml --extra-vars="zsh_user=$(whoami)"

# TODO: add ZSH configuration from github.com/shah/engineering-sandbox-debian as the common config

echo "****************************************************"
echo "** Netspective Service Appliance setup complete.  **"
echo "** ---------------------------------------------- **"
echo "** Exit the shell, then log back in to continue   **"
echo "** the appliance setup process.                   **"
echo "****************************************************"
