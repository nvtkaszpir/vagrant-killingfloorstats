About
==================================================

Example app from beginning to end, using Infrastructure as Code idea.


Requirements
==================================================

Your local machine should have the following:

* 2 CPU cores, 2GB of RAM, about 8GB of disk space required for vm
* vagrant > 1.2.x - download and install https://www.vagrantup.com/
* vagrant plugin librarian-puppet, install it using ``vagrant plugin install vagrant-librarian-puppet``
* rsync client
* git client - for librarian-puppet
* access to the Internet without proxies (not supported in this setup via vagrant/bootstrap/puppet)
* jmeter 3.1 with plugin manager and plugins for benchmark tests
* ruby 2.x.x and bundler for running more advanced tests

Known limitation
==================================================

* try vagrant 1.9.x from official download page, cause system packages may have issues
* you may need to adjust Vagrantfile depending on your vm provider and rsync options
* centos 7.3 as base vagrant box - tested with qemu/kvm, virtualbox
* monit as simple monitoring, it provides web interface (see below)
* monit does not send any notifications in this setup.
* configuration management using puppet 3.8.7 - a bit ancient nowadays...
* cockpit does not start on first puppet run (because it generates cert on first start), so exec puppet twice
* cockpit is shut down as service by sytemd after some time, triggering connection on port 9090 launches it again

Directory structure
==================================================

* ``src/`` - app code
* ``vagrant/`` - provisioning vagrant virtual machines code - bootstrap scripts and puppet
* ``test/`` - and especially .jmx file - for performance testing, see below

Starting up
==================================================

To start from scratch

```bash

vagrant plugin install vagrant-librarian-puppet
vagrant up app

```

and virtual machine should be created.

The following addresses are then available:

* http://127.0.0.1:8183/KillingFloorStats/ for app interface
* https://127.0.0.1:12812/ for monitoring app interface (admin:somepassword)
* http://127.0.0.1:19090/ for general server status (vagrant:vagrant)

Inside VM
==================================================

See in vm named ``app``:

* ``/var/log/monit`` - monit logs which checks service status

* ``/var/log/nginx/access.log`` - web server logs
* ``/var/log/nginx/error.log`` - web server logs
* ``/var/log/php-fpm/error.log`` - web for app errors log
* ``/var/log/php-fpm/www-slow.log`` - PHP slow log

* ``/var/log/nginx/kfstats.hlds.pl.access.log`` - specific logs for the app
* ``/var/log/nginx/kfstats.hlds.pl.error.log`` - specific logs for the app

Rebuilding Vagrant vm
==================================================

In order to re-provision modified puppet code you may need to run below commands, sometimes twice:

```bash
vagrant rsync app
vagrant provision app --provider=puppet
```

This is due the fact, that librarian-puppet plugin for vagrant runs after rsync and does not send
files to hosts...

Tuning
==================================================

Vagrant VM tune
--------------------------------------------------

See header of the Vagrantfile to adjust number of CPU cores and memory.

Vagrant with custom provider
--------------------------------------------------

Instead of VirtualBox you can use qemu/KVM with libvirt:

```bash
vagrant up app --provider=libvirt
```

For LXC you should see for example https://app.vagrantup.com/frensjan/boxes/centos-7-64-lxc or custom image,
but notice that then port forwarding may not work - find out container IP and use direct app ports, in Puppet/hiera.


Puppet tuning
--------------------------------------------------

* Puppetfile - used to manage puppet modules.
See ``vagrant/puppet/Puppetfile``, in case of problems like ``Could not resolve the dependencies.`` try on your machine:

```bash
gem instal librarian-puppet
cd vagrant/puppet/Puppetfile
librarian-puppet clean
librarian-puppet install --verbose
```

* See ``vagrant/puppet/`` for the configuration setting using Puppet.
See especially``vagrant/puppet/hieradata/roles/app.yaml`` for app server tweaks like php settings, nginx and so on


Testing
==================================================

In ``test/`` you have various test suites:

* ``integration/inspec`` - for testing vm after provisioning
* ``benchmarks/`` - performance test in jmeter 3.1 (requires some jmeter plugins like 3 Basic Graps, 5 Additional Graphs, Custom Thread Groups, Composite timeline graph)


Benchmark test
--------------------------------------------------

Install jmeter 3.1 and plugins using Plugins Manager.
Load test file from ``test/benchmark/stress.jmx`` and adjust default testing parameters for HTTP request, like IP and port.

In the future this could be expanded so that jmeter would take that data from env vars.

TODO: add exact info about jmeter plugins


Inspec test - checking dependencies
--------------------------------------------------

Example running integration tests with inspec against vagrant.

First, you must resolve inspec vendors (and refresh .lock files):

```bash
inspec vendor test/integration/inspec/profiles/nvtkaszpir-killingfloorstats/
```

Inspec test - vagrant
--------------------------------------------------

After resolving inspec vendor dependencies you can execute tests on vagrant box:

```bash
inspec exec test/integration/inspec/profiles/nvtkaszpir-killingfloorstats -t ssh://127.0.0.1:2222 --user=vagrant --key-files=.vagrant/machines/app/virtualbox/private_key --sudo --profiles-path=test/integration/inspec/

```

If you use custom provider for vagrant, then you may need to adjust ssh:// and --key-files to suit your setup.
For example I use libvirt provider, so I use below command:

```bash
inspec exec test/integration/inspec/profiles/nvtkaszpir-killingfloorstats -t ssh://192.168.121.224 --user=vagrant --key-files=.vagrant/machines/app/libvirt/private_key --sudo --profiles-path=test/integration/inspec/
```

Inspec test - remote host
--------------------------------------------------

Example running integration tests with inspec against normal server:

```bash
inspec exec test/integration/inspec/profiles/nvtkaszpir-killingfloorstats -t ssh://some-user@some-host.tld --user=vagrant --key-files=/home/kaszpir/.ssh/id_rsa --sudo --profiles-path=test/integration/inspec/

```


Notice that cockpit service can be down if not used for few mintues,
it is automatically spawned by systemd on port 9090 activity.
