#!/bin/bash
#set -x

# execute inspec profile test based on vagrant host settings

VH=${VAGRANT_HOST:-"app"}
export VH
echo VH="${VH}"

inspec exec \
	test/integration/inspec/profiles/nvtkaszpir-kf-${VH} \
	--profiles-path=test/integration/inspec/ \
	-t ssh://$(vagrant ssh-config ${VH} | grep 'HostName ' | awk '{print $2}') \
	--user=$(vagrant ssh-config ${VH} | grep 'User ' | awk '{print $2}') \
	--key-files=$(vagrant ssh-config ${VH} | grep 'IdentityFile ' | awk '{print $2}') \
	--sudo
