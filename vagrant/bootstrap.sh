#!/usr/bin/env bash
puppet_version_apt=puppet
puppet_version_yum=puppet-3.8.7

echo "" >/tmp/provision.shell.log
echo "========================================================================"
echo "Starting bootstrap."
if [ -f "/etc/redhat-release" ];then
	echo "Redhat or something...."
	RELEASEVER=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))
	yum clean all
	# we will need that to lock puppet version
	yum install -y yum-versionlock epel-release wget mc
	# install key from puppetabs
	# install puppetlabs repo
	yum list installed ${puppet_version_yum}
	if [ $? -ne 0 ]; then
		echo "Installing puppet ${puppet_version_yum}"
		wget -q https://yum.puppetlabs.com/RPM-GPG-KEY-puppet -O /tmp/RPM-GPG-KEY-puppet
		rpm --import /tmp/RPM-GPG-KEY-puppet
		rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-${RELEASEVER}.noarch.rpm
		yum install -y ${puppet_version_yum} >> /tmp/provision.shell.log 2>&1
		yum versionlock puppet
	else
		echo "Puppet already installed"
	fi
	# run update
	echo "yum update..."
	yum -y update >> /tmp/provision.shell.log 2>&1


fi


if [ -f "/etc/debian_version" ];then
	echo "Debian/Ubuntu or something...."
	. /etc/lsb-release
	# TODO: detect debian/ubuntu
    echo "Replacing /etc/apt/sources.list"
		cat > /etc/apt/sources.list << EOFDEB
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME} main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME}-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME}-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt ${DISTRIB_CODENAME}-security main restricted universe multiverse
EOFDEB

	echo "Installing puppet ${puppet_version_apt}"
	apt-get install -y ${puppet_version_apt} mc >> /tmp/provision.shell.log 2>&1
	echo "installing python-software-properties mc..."
	apt-get install -y python-software-properties mc >> /tmp/provision.shell.log 2>&1

	echo "apt-get update..."
	apt-get update >> /tmp/provision.shell.log 2>&1
	echo "apt-get dist-update..."
	apt-get dist-upgrade -y >> /tmp/provision.shell.log 2>&1

fi
# AWS specific

if [ "$(facter|grep '^virtual => '|awk '{print $3}')" == "xen" ]; then
# aws
	echo "Hostname: $(hostname)"
	echo "     VPN: $(facter 2>/dev/null | grep ipaddress_tun0 | awk '{print $3}')"
	echo "  Public: $(curl http://169.254.169.254/latest/meta-data/public-hostname 2> /dev/null)"
	echo "  Public: $(curl http://169.254.169.254/latest/meta-data/public-ipv4 2> /dev/null)"
	echo "Internal: $(curl http://169.254.169.254/latest/meta-data/local-hostname 2> /dev/null)"
	echo "Internal: $(curl http://169.254.169.254/latest/meta-data/local-ipv4 2> /dev/null)"
	# this is so that vagrant provisioner will not launch too early
	# also placing any package installation in this file is deprecated
	# use cloudinit file for that.
	count=0;
	count_max=60;
	sleep_seconds=10; # 60 * 10 = 600s = 10min
	while ! grep "final-message" /var/log/cloud-init.log >/dev/null 2>&1; do
		echo "Waiting for cloudinit to finish. $count of $count_max, sleeping $sleep_seconds";
		sleep ${sleep_seconds};
		((count++));
		if [ $count -gt $count_max ]; then
			echo "Error: waited too long for cloudinit. Giving up.";
			exit 1;
		fi;
	done;
fi

# VirtualBox specific
if [ "$(facter|grep '^virtual => '|awk '{print $3}')" == "virtualbox" ]; then
	echo "Here used to be vbguest additions, but there is a vagrant plugin for that"
fi


# fix vagrant sudoers
echo "Fix vagrant sudoers in /etc/sudoers.d/vagrant"
echo "vagrant    ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant

echo "========================================================================"
echo "See /tmp/provision.shell.log"
echo "========================================================================"
echo "End of bootstrap"
echo "========================================================================"
# fake proper exit to execute other tasks
exit 0
