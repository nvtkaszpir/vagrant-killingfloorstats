#!/bin/bash
#set -x

# execute inspec profile test based on vagrant host settings

VH=${VAGRANT_HOST:-"app"}
export VH
echo VH="${VH}"

inspec vendor --overwrite \
	test/integration/${VH}/

inspec exec \
	test/integration/${VH}/ \
	--profiles-path=test/integration/ \
	-t ssh://$(vagrant ssh-config ${VH} | grep 'HostName ' | awk '{print $2}') \
	--user=$(vagrant ssh-config ${VH} | grep 'User ' | awk '{print $2}') \
	--key-files=$(vagrant ssh-config ${VH} | grep 'IdentityFile ' | awk '{print $2}') \
	--sudo
