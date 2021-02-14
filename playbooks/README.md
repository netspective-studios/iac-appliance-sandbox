# Appliance-neutral Ansible Playbooks

Each playbook has the following format:

`name.[target].ansible-playbook.yml`

The `target` is *by convention*:

* `appl` if the playbook is modifying the *appliance* (system level, for all users). 
  * Whenever possible, **do not** modify the appliance. 
  * Only modify the appliance when a  service or component should not be defined per-user. 
  * When installing something at the appliance level, use common system conventions such `/bin`, `/usr/bin`, and `/opt/`.
* `user` if the playbook is modifying the *user*. Whenever possible, always install services, components, etc. for a user.
  * Never hard-code locations, use NSSA's Ansible variables like `{{ nssa_home_user }}` and `{{ nssa_home_user_bin }}` 
  * `nssa_home_user` is typicall set to `/home/user/.nssa` but can be configured by the appliance or deployment operator
  * `nssa_home_user_bin` is typicall set to `/home/user/.nssa/bin` but can be configured by the appliance or deployment operator

The names of the playbooks in this directory do not include numeric prefixes but when they are symlinked to their respective appliances, they use these conventions:

`[000]_name.[target].ansible-playbook.yml`

The `000` is *by convention*:

* `000`-`499` for appliance (system) level changes
* `500`-`999` for user-level changes