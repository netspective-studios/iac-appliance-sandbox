#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

source `dirname $0`/setup-common-configure.sh

title() {
    local color='\033[1;37m'
    local nc='\033[0m'
    printf "\n${color}$1${nc}\n"
}

# TODO: move osQuery to Ansible installation?
#       ansible-galaxy install apolloclark.osquery
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

title "Run all numbered playbooks for $(whoami) appliance $NSSA_APPLIANCE from $NSSA_APPLIANCE_PLAYBOOKS_HOME"
for playbook in `ls $NSSA_APPLIANCE_PLAYBOOKS_HOME/*.ansible-playbook.yml | egrep "^$NSSA_APPLIANCE_PLAYBOOKS_HOME/[0-9]" | sort -V`; do 
	sudo ansible-playbook -i "localhost," -c local $playbook --extra-vars="nssa_user=$(whoami) nssa_home=$NSSA_HOME nssa_appliance_id=$NSSA_APPLIANCE nssa_appliance_defn_home=$NSSA_APPLIANCE_HOME nssa_appliance_conf_home=$NSSA_APPLIANCE_CONF_HOME nssa_appliance_secrets_home=$NSSA_APPLIANCE_SECRETS_HOME nssa_is_wsl=$NSSA_IS_WSL"
done;

echo "******************************************************************"
echo "** Netspective Studios Service Appliance (NSSA) setup complete. **"
echo "** ------------------------------------------------------------ **"
if [[ $NSSA_IS_WSL eq 0]]; then
    echo "** Please reboot and then the appliance will be ready for use:  **"
    echo "**                                                              **"
    echo "** > sudo reboot                                                **"
else
    echo "** To use your new appliance, exit your WSL distribution and    **"
    echo "** restart the shell.                                           **"
fi
echo "******************************************************************"
