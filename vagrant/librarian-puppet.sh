#!/usr/bin/env bash
echo "Running librarian-puppet scripts"
PUPPET_DIR=${1:-"/vagrant/puppet"}
export LC_ALL=C
export PATH="/usr/local/bin:${PATH}"
gem install librarian-puppet

yum install -y git || true
apt-get install -y git || true

cd ${PUPPET_DIR}
librarian-puppet install --verbose
