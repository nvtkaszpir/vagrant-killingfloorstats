#!/usr/bin/env bash
HIERA_CONFIG=${HIERA_CONFIG:-"/vagrant/puppet/hiera.yaml"}
PUPPET_DIR=${PUPPET_DIR:-"/vagrant/puppet"}
PUPPET_MANIFEST=${PUPPET_MANIFEST:-"default.pp"}
PUPPET_MANIFST_DIR=${PUPPET_MANIFST_DIR:-"manifests/"}
PUPPET_MODULEPATH=${PUPPET_MODULEPATH:-"/vagrant/puppet/modules:/vagrant/puppet/local_modules"}
PUPPET_OPTS=${PUPPET_OPTS:-""}
PUPPET_VERBOSE=${PUPPET_VERBOSE:-""}
PUPPET_ENVIRONMENT=${PUPPET_ENVIRONMENT:-"production"}

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
echo PUPPET_OPTS=${PUPPET_OPTS}
echo HIERA_CONFIG=${HIERA_CONFIG}
echo PUPPET_MANIFEST=${PUPPET_MANIFEST}
echo PUPPET_MANIFST_DIR=${PUPPET_MANIFEST_DIR}
echo PUPPET_MODULEPATH=${PUPPET_MODULEPATH}
echo PUPPET_DIR=${PUPPET_DIR}
echo PUPPET_ENVIRONMENT=${PUPPET_ENVIRONMENT}

# below is needed for hiera to work
cd ${PUPPET_DIR}

echo executing puppet run \
puppet apply \
${PUPPET_OPTS} \
--modulepath=${PUPPET_MODULEPATH} \
--hiera_config=${HIERA_CONFIG} \
--environment=${PUPPET_ENVIRONMENT} \
${PUPPET_DIR}/${PUPPET_MANIFST_DIR}/${PUPPET_MANIFEST}

puppet apply \
${PUPPET_OPTS} \
--modulepath=${PUPPET_MODULEPATH} \
--hiera_config=${HIERA_CONFIG} \
--environment=${PUPPET_ENVIRONMENT} \
${PUPPET_DIR}/${PUPPET_MANIFST_DIR}/${PUPPET_MANIFEST}
