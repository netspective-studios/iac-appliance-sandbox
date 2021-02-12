#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

title() {
    local color='\033[1;37m'
    local nc='\033[0m'
    printf "\n${color}$1${nc}\n"
}

title "Install osQuery"
export OSQUERY_KEY=1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $OSQUERY_KEY
sudo add-apt-repository 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
sudo apt-get update
sudo apt-get install -y osquery

title "Install roles from Ansible Galaxy"
sudo ansible-galaxy install geerlingguy.docker
sudo ansible-galaxy install bertvv.samba
sudo ansible-galaxy install geerlingguy.kubernetes

title "Finish setting up shell"
zsh -i -c setupsolarized dircolors.256dark

export NSSA_HOME=/etc/netspective-service-appliances
title "Run all numbered playbooks for $(whoami) appliance $NSSA_APPLIANCE from $NSSA_APPLIANCE_PLAYBOOKS"
for playbook in `ls $NSSA_APPLIANCE_PLAYBOOKS/*.ansible-playbook.yml | egrep "^$NSSA_APPLIANCE_PLAYBOOKS/[0-9]" | sort -V`; do 
	sudo ansible-playbook -i "localhost," -c local $playbook --extra-vars="NSSA_user=$(whoami) nfs_status=$(echo $NSSA_FF_SETUP_NSF) k8s_status=$(echo $NSSA_FF_SETUP_K8s)"
done;

echo "****************************************************"
echo "** Netspective Service Appliance setup complete.  **"
echo "** ---------------------------------------------- **"
echo "** If this is a bare metal (physical) server or   **"
echo "** VM please reboot and then the appliance will   **"
echo "** be ready for use:                              **"
echo "**                                                **"
echo "** > sudo reboot                                  **"
echo "****************************************************"
