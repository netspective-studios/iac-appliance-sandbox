#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

source `dirname $0`/setup-common-configure.sh

# TODO: if a Ansible playbook doesn't need super user, put it in this script