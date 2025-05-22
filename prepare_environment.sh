#!/bin/bash

set -x
set -euo pipefail

. .secrets

GITHUB_OWNER=cbartz
MICROSTACK_RISK=edge
RAM_MEMORY=20GiB
CPUS=12
# Check the glance configuration in openstack-user-data if you want to decrease the disk size...
ROOT_DISK_SIZE=100GiB

REPOSITORY=${GITHUB_OWNER}/github-runner-operator

export MICROSTACK_RISK
export REPOSITORY
export GITHUB_TOKEN

DEBIAN_FRONTEND=noninteractive sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt-get install retry -y

lxc delete openstack --force || :

lxc init ubuntu:24.04 openstack --vm -c limits.cpu=${CPUS} -c limits.memory=${RAM_MEMORY} -d root,size=${ROOT_DISK_SIZE} --config=user.user-data="$(cat ./openstack-user-data | envsubst '$MICROSTACK_RISK,$REPOSITORY,$GITHUB_TOKEN')"

echo "Starting at $(date)"
lxc start openstack

lxc exec openstack -- cloud-init status --wait

echo "End at $(date)"
