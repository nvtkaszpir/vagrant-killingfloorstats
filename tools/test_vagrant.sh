#!/usr/bin/env bash
# cleanup current setup
vagrant destroy -f

export VAGRANT_BOX_UPDATE_CHECK_DISABLE=1


DATE_START=$(date +%Y-%M-%d_%H-%M-%S)
vagrant up
tools/inspec_vagrant.sh
RESULT=$?
DATE_STOP=$(date +%Y-%M-%d_%H-%M-%S)

echo "start $DATE_START"
echo "stop  $DATE_STOP"
exit $RESULT
