# Services Appliances Infrastructure as Code (IaC)

Netspective Studios Service Appliance (NSSA) framework.

**STATUS**: *This project is work in progress and is not ready for even basic experimentation.*

MAJOR changes TODO:
* Migrate away from BASH to Ansible wherever possible (e.g. osQuery in setup.sh) -- meaning, `/bin/bootstrap.sh` and `/bin/*.sh` should be as thin as possible
* Use [ASDF](https://asdf-vm.com/) to manage multiple runtime versions with a single CLI tool
  * Use [Ansible role to install ASDF](https://github.com/markosamuli/ansible-asdf)
  * Use [ASDF plugins](https://asdf-vm.com/#/plugins-all) for all lanaguages we support instead of creating custom Ansible roles for each language
* Try to remove all requirements for `sudo` in shell scripts in favor of Ansible [become](https://docs.ansible.com/ansible/latest/user_guide/become.html#become-directives)
* Integrate [Nomad](https://www.nomadproject.io/), a simple and flexible workload orchestrator to deploy and manage containers and non-containerized applications across on-prem and clouds at scale, into NSSA. Allowing both Nomad and Docker together might be very powerful for edge servers.
* Integrate [ARA](https://github.com/ansible-community/ara) for recording and observing Ansible Playbook output
* Try to make sure all the Ansible scripts could possibly be used to generate Dockerc containers, too
* Implementation Ansible Galaxy automation
* Implement TODOs in all *.sh and other sources

Common services appliance(s) IaC for creating:

* Netspective Studios **Buildmasters** (VMs or bare metal servers allowing CI/CD targets to *build* determinstically reproducible polyglot software)
* Netspective Studios **Engineering Sandboxes** (WSL, VMs, or bare metal servers for engineering polyglot software in a determinstically reproducible way across developers and development teams)
* Netspective Studios *Containers* (Ansible called within containers to simplify `Dockerfile` configurations?)

## CLI operations controller

NSSA CLI operations are performed with the `just` [command runner](https://github.com/casey/just). The `nssactl` in the root directory of this repo is an executable `just` Justfile for controlling NSSA operations.

To list the commands available:

```bash
./nssactl --list
```

To see which appliances are availabe:

```bash
./nssactl inspect-appliance-types
```

## Server software requirements

Any Debian based OS (e.g. Ubuntu) on a virtual or physical machine which supports Ansible and all dependencies. Unless you're an expert with [Ansible](https://www.ansible.com/) skills, use a WSL2 Debian instance for *Engineering Sandboxes* or [Debian network install](https://www.debian.org/CD/netinst/) for a custom VM or using appliances on bare metal. The network install creates the smallest footprint server so it's the most secure and requires minimal hardening for security.

TODO: We may allow non-Debian OSs such Windows, MacOS, or other Linux distributions if there's enough interest and contributors

## Setup the operating system

### Engineering Sandbox Setup on Windows 10

If you're using Windows 10 with WSL2, create a "disposable" Debian WSL2 instance using Windows Store. This project treats the WSL2 instance as "disposable" meaning it's for development only and can easily be destroyed and recreated whenever necessary. The cost for creation and destruction for a Engineering Sandbox should be so low that it should be treated almost as a container rather than a VM. 

### Service Appliance Sandbox on any VM or bare metal server

Setup a bare metal server or Windows Hyper-V, VMware, VirtualBox, or other hypervisor VM:

* RAM: minimum 2048  megabytes, preferably **4096 megabytes**
* Storage: minimum 32 gigabytes, preferably **256 gigabytes**
* Network: **Accessible outbound to the Internet** (both IPv4 and IPv6), inbound access not required
* Firewall Route: The publically accessible IP can point to this server, a Linux firewall is automatically managed by the appliance

When you install your OS, use the smallest footprint possible. The smaller the footprint, the safer and more secure the appliance. You can use most of the defaults, but provide the following defaults when you are asked to make choices:

* Hostname: **engineering** (devl), **assurance** (QA) or **appliance** (production).
* Default User Full Name: **Admin User**
* Default User Name: **admin**
* Default User Password: **adminDefault!**
* Disk Partitioning: **Guided - use entire disk**
* PAM Configuration: **Install security updates automatically**
* Software Packages: *OpenSSH is the only package that must be installed by default*

NOTE: the user you create is called the *admin user* below. 

## Prepare your appliance for software

After your operating system installation is completed via either WSL, a VM, or bare metal deployment, log into the server as the *admin user* (see above).

Bootstrap the core utilities:

    sudo apt update && sudo apt install net-tools curl -y && \
    curl https://raw.githubusercontent.com/netspective-studios/service-appliances/master/bin/bootstrap.sh | bash

After `bootstrap.sh` is complete, exit the shell.

## Review your specific appliance variables

After you've exited, log back in as the *admin user* and review the `secrets.ansible-vars.yml` file to customize it for your installation. 

    cd /etc/netspective-service-appliances/[applianceId]
    sudo vi secrets.d/secrets.ansible-vars.yml

The **secrets-tmpl.ansible-vars.yml** file is a template (sample), and the **secrets.ansible-vars.yml** is what will be used by the Ansible and related setup utilities.

If you have any custom playbooks, add them to `/etc/netspective-service-appliances/playbooks` and symlink them to the proper `/etc/netspective-service-appliances/appliances/[applianceId]/playbooks.d`. The `bin/setup.sh` utility will run all numbered playbooks in `appliances/[applianceId]/playbooks.d` in numerical order (where `[type]` is, for example, `buildmaster` or `engineering-sandbox`).

## Install software

    cd /etc/netspective-service-appliances
    ./nssactl inspect-appliances-types
    ./nssactl setup-appliance [appliance_type_id]

After setup is completed, reboot the appliance if a VM or bare metal (or just close and reopen if WSL on Windows):

    sudo reboot

## Batteries Included

The NSSA comes with everything you need to run a secure, minimally hardended, appliance for custom on-premise or cloud software for containerized or non-containerized workloads. 

### Installed for all appliances

* ZSH with Oh My ZSH! and Antigen
* Ansible and ARA
* osQuery
* Outbound SMTP relay via DragonFly MTA (dma) and mailutils, no incoming e-mails are allowed though
* Python and PIP
* `just`, `htop`, `jsonnet`, `jq`

### Available for specific appliances (see `README.md` in each appliance for what's installed)

* UFW and fail2ban (useful for non-WSL VMs bare metal servers)
* Docker with [docker-gen](https://github.com/jwilder/docker-gen)
* [Nomad](https://www.nomadproject.io/) workload orchestrator
* Samba with admin home available as a share
* `prometheus-node-exporter`
* `prometheus-osquery-exporter`

