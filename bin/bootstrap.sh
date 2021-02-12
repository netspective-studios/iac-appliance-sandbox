#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# NSSA_ prefix should used for all Netspective Studios Service Appliance (NSSA) env vars

export NSSA_IS_WSL=0
if [[ "$(< /proc/version)" == *@(Microsoft|WSL)* ]]; then
    if [[ "$(< /proc/version)" == *@(WSL2)* ]]; then
        export NSSA_IS_WSL=2
    else
        export NSSA_IS_WSL=1
    fi
fi

# TODO: check if non-Debian (e.g. non-Ubuntu) based OS and stop; later we'll add ability for non-Debian distros

export NSSA_HOME=/etc/netspective-service-appliances
export NSSA_ALL_ANSIBLE_PLAYBOOKS=${NSSA_HOME:-$NSSA_HOME/playbooks}

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

title "Download distribution into $NSSA_HOME"
sudo git clone --recurse https://github.com/netspective-studios/service-appliances $NSSA_HOME

title "Provision ARA setup playbook"
sudo ansible-playbook -i "localhost," -c local $NSSA_ALL_ANSIBLE_PLAYBOOKS/ara.ansible-playbook.yml --extra-vars="nssa_is_wsl=$NSSA_IS_WSL"

title "Provision ZSH setup playbook for $(whoami)"
sudo ansible-playbook -i "localhost," -c local $NSSA_ALL_ANSIBLE_PLAYBOOKS/zsh.ansible-playbook.yml --extra-vars="zsh_user=$(whoami) nssa_is_wsl=$NSSA_IS_WSL"

echo "****************************************************"
echo "** Netspective Service Appliance setup complete.  **"
echo "** ---------------------------------------------- **"
echo "** Exit the shell, then log back in to continue   **"
echo "** the appliance setup process.                   **"
echo "****************************************************"
