#!/usr/bin/env bash
# this file executes puppet
# make sure to be in the directory where puppet resides (not to mention hiera)
# parameters are relative to current path
PUPPET_DIR=${PUPPET_DIR:-"/etc/puppet"}
PUPPET_ENVIRONMENT=${PUPPET_ENVIRONMENT:-"production"}
PUPPET_HIERA_CONFIG=${HIERA_CONFIG:-"hiera.yaml"}
PUPPET_MANIFEST=${PUPPET_MANIFEST:-"default.pp"}
PUPPET_MANIFST_DIR=${PUPPET_MANIFST_DIR:-"manifests/"}
PUPPET_MODULEPATH=${PUPPET_MODULEPATH:-"modules:local_modules"}
PUPPET_OPTS=${PUPPET_OPTS:-""}
PUPPET_VERBOSE=${PUPPET_VERBOSE:-""}

case $PUPPET_VERBOSE in
"1")
	PUPPET_OPTS+=" --verbose "
	;;
"2")
	PUPPET_OPTS+=" --debug "
	;;
"3")
	PUPPET_OPTS+=" --verbose --debug --trace"
	;;
"*")
	PUPPET_OPTS+=" --verbose --debug"
	;;

esac

echo "Running puppet apply scripts..."
echo PUPPET_DIR=${PUPPET_DIR}
echo PUPPET_ENVIRONMENT=${PUPPET_ENVIRONMENT}
echo PUPPET_HIERA_CONFIG=${PUPPET_HIERA_CONFIG}
echo PUPPET_MANIFEST=${PUPPET_MANIFEST}
echo PUPPET_MANIFST_DIR=${PUPPET_MANIFEST_DIR}
echo PUPPET_MODULEPATH=${PUPPET_MODULEPATH}
echo PUPPET_OPTS=${PUPPET_OPTS}

echo executing puppet run \
cd ${PUPPET_DIR} \&\& puppet apply \
${PUPPET_OPTS} \
--modulepath=${PUPPET_MODULEPATH} \
--hiera_config=${PUPPET_HIERA_CONFIG} \
--environment=${PUPPET_ENVIRONMENT} \
${PUPPET_MANIFST_DIR}/${PUPPET_MANIFEST}

cd ${PUPPET_DIR} && puppet apply \
${PUPPET_OPTS} \
--modulepath=${PUPPET_MODULEPATH} \
--hiera_config=${PUPPET_HIERA_CONFIG} \
--environment=${PUPPET_ENVIRONMENT} \
${PUPPET_MANIFST_DIR}/${PUPPET_MANIFEST}
