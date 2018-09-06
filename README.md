About
==================================================

Example app from beginning to end, using Infrastructure as Code idea.
Actually the app is just an add-on to play around with creating fully working CI/CD repo :)

Requirements
==================================================

Your local machine should have the following:

* 2 CPU cores, 2GB of RAM, about 8GB of disk space required for vm
* vagrant > 1.2.x - download and install from [official site](https://www.vagrantup.com/)
* rsync client
* access to the Internet without proxies (not supported in this setup via vagrant/bootstrap/puppet)
* jmeter 3.1 with [plugin manager and plugins](https://jmeter-plugins.org/) for benchmark tests
* ruby 2.x.x and bundler for running more advanced tests (inspec), use [rbenv.org](http://rbenv.org/)

Known limitation
==================================================

* don't try to use it under Windows platform, there is too much dependency to ruby not to support
  it here. (TODO: get rid of vagrant plugin, move all into vm: rbenv + gem + librarian-puppet,
  adjust provisioning scripts) - so right now you can create vm to create vm... :)
* try vagrant 1.9.x from official download page, cause system packages may have issues
* you may need to adjust Vagrantfile depending on your vm provider and rsync options
* centos 7.3 as base vagrant box - tested with qemu/kvm, virtualbox
* monit as simple monitoring, it provides web interface (see below)
* monit does not send any notifications in this setup.
* configuration management using puppet 3.8.7 - a bit ancient nowadays...
* cockpit does not start on first puppet run (because it generates cert on first start),
  so exec puppet twice
* cockpit is shut down as service by sytemd after some time, triggering connection on port 9090
  launches it again (surprisingly that is not the case under LXC)


Cloning the repo
==================================================

Remember to download git repo with submodules:

```bash
git clone --recursive https://github.com/nvtkaszpir/vagrant-killingfloorstats
```

More at [official git book](https://git-scm.com/book/en/v2/Git-Tools-Submodules).


Directory structure
==================================================

* ``src/`` - app code
* ``vagrant/`` - provisioning vagrant virtual machines code - bootstrap scripts and puppet
* ``test/`` - and especially .jmx file - for performance testing, see below

Starting up
==================================================

To start from scratch

```bash
rbenv install 2.4.4
rbenv local 2.4.4
gem install bundler
bundle install

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
vagrant provision app
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

For LXC you should see for example [this](https://app.vagrantup.com/frensjan/boxes/centos-7-64-lxc)
or custom image, but notice that then port forwarding may not work - find out container
IP and use direct app ports, in Puppet/hiera.


Puppet tuning
--------------------------------------------------

* Puppetfile - used to manage puppet modules. It will be updated during provision but is not rsynced
  back to your host. See ``vagrant/puppet/Puppetfile``, in case of problems like
  ``Could not resolve the dependencies.`` try on your machine:

```bash
gem instal librarian-puppet
cd vagrant/puppet/Puppetfile
librarian-puppet clean
librarian-puppet install --verbose
```

* See ``vagrant/puppet/`` for the configuration setting using Puppet.

See especially``vagrant/puppet/hiera/production/roles/app.yaml`` for app server tweaks.


Testing
==================================================

In ``test/`` you have various test suites:

* ``integration/app/inspec`` - for testing our ``app`` vm after provisioning
* ``benchmarks/`` - performance test in jmeter 3.1 (requires some jmeter plugins like
   3 Basic Graps, 5 Additional Graphs, Custom Thread Groups, Composite timeline graph).


Benchmark test
--------------------------------------------------

Install jmeter 3.1 and plugins using Plugins Manager [here](https://jmeter-plugins.org/).
Load test file from ``test/benchmark/stress.jmx`` and adjust default testing parameters for
HTTP request, like IP and port.

In the future this could be expanded so that jmeter would take that data from env vars.

TODO: add exact info about jmeter plugins
TODO: parametrize .jmx file to load vars from env


Inspec test - checking dependencies
--------------------------------------------------

Example running integration tests with inspec against vagrant. Notice, that it requires ruby on local machine.

Before running inspec, update ruby using rbenv and gems, short version:

```bash
rbenv install 2.4.4
rbenv local 2.4.4
gem install bundler
bundle install
```

After that, you must resolve inspec vendors (and refresh .lock files):

```bash
inspec vendor test/integration/app --overwrite
```

Inspec test - vagrant
--------------------------------------------------

After resolving inspec vendor dependencies you can execute tests on vagrant box:

```bash
inspec exec test/integration/app/ \
    -t ssh://127.0.0.1:2222 \
    --user=vagrant \
    --key-files=.vagrant/machines/app/virtualbox/private_key \
    --sudo \
    --profiles-path=test/integration/

```

If you use custom provider for vagrant, then you may need to adjust ssh:// and --key-files
to suit your setup. For example I use libvirt provider, so I use below command:

```bash
inspec exec test/integration/app/ \
    -t ssh://192.168.121.224 \
    --user=vagrant \
    --key-files=.vagrant/machines/app/libvirt/private_key \
    --sudo \
    --profiles-path=test/integration/
```

See ``vagrant ssh-config`` for more details.

Inspec test - remote host
--------------------------------------------------

Example running integration tests with inspec against normal server:

```bash
inspec exec test/integration/app/ \
    -t ssh://some-user@some-host.tld \
    --user=vagrant \
    --key-files=/home/kaszpir/.ssh/id_rsa \
    --sudo \
    --profiles-path=test/integration/

```

Notice that cockpit service can be down if not used for few minutes,
it is automatically spawned by systemd on port 9090 activity.


Running tests with test-kitchen
--------------------------------------------------

If you have installed gems like above, you should be able to also use test-kichen to verify
different configurations - now there is Centos only with single app.
More about test-kitchen can be found at [kitchen.ci](http://kitchen.ci/).

Kitchen takes two files for setup: ``.kitchen.yml`` and ``.kitchen.local.yml``.
In this repot there is more:

* ``.kitchen.yml`` - uses standard vagrant with virtualbox provider
* ``.kitchen.lxc.yml`` - if you use LXC you may find it useful.
* ``.kitchen.libvirt.yml`` - if you use qemu/kvm with libvirt
* ``.kitchen.libvirt.jenkins.yml`` - as above but outputs inspec tests as junit xml to reports dir.

Copy one of above files to ``.kitchen.local.yml``, depending on your favorite provider.

Next, issue ``kitchen status`` to see machine status - should show a list.

* Use ``kitchen converge`` to create instances.
* Use ``kitchen verify`` to check if instances conform with inspec tests.
* Use ``kitchen destroy`` to delete create machine after work.
* Use ``kitchen test`` to run all above in single run.

Any error will abort creating of other machines if ran in sequence.
Usally you want to run converge and verify, till tests and provisioning is complete, then re-run
whole process again to create instances from scratch.

Notice that test-kitchen with kitchen-puppet plugin takes care to execute librarian-puppet
locally on your machine prior creating virtual machines - so it will download puppet modules,
and avoids installing rbenv + gems on the guest (as it is done with standard Vagrantfile).

So test-kitchen can be used as a base to expand to different platforms and provisioners,
for example:

* add Debian and Ubuntu as platforms
* add new apps suites, for example with different PHP version
* add new provisioners like Ansible

Further expanding
==================================================

Important
--------------------------------------------------

* contributing section (if anyone really cares)
* jenkinsfile or jenkins job DSL, build with junit - make bagno.hlds.pl feel the pain of existence
* puppet - add location to hiera, expand hiera per location, add vagrant as location + facts
* puppet - add firewall
* puppet - production should eradicate vagrant user and sudoers
* tags, cause repos love tags
* vagrant - add xdebug
* simple puppet verifier?
* parametrize jmeter + performance tests with jmeter
* vagrant push
* Fabric deployment script
* Ansible deployment script
* packer templates
* nginx microcaching, casue our super-duper app does nothing fancy, can be cached for 5min
* makefile or gradle? ruby, python soon, java, groovy, ... someone said phing?

Later
--------------------------------------------------

* more detailed inspec tests, now thery are really super simple
* more sane test for monit if app still works
* puppet deployment script (yeah, go mental, puppet does not really works well with it)
* puppet - hiera eyaml?
* migrate to puppet 4 or beyond!
* migrate from pupet to ansible
* use blazemeter taurus for above?
* docker, yeah, we need docker cause docker, and devops, docker, and docker!
* migrate to docker-compose or something like that
* integrate code smells / sonarqube
* integrate security scans
* add travis ...for...what? afair it cannot do nested vms
