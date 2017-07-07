#!/usr/bin/env bash
# cleanup current setup
vagrant destroy -f

export VAGRANT_DEFAULT_PROVIDER=libvirt
tools/test_vagrant.sh
