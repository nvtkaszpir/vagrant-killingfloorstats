# -*- mode: ruby -*-
# vi: set ft=ruby :
#ENV['VAGRANT_DEFAULT_PROVIDER'] = 'lxc'
V_CPU = 2 # in cores
V_MEM = 512 # in megabytes per core
V_MEM_TOTAL = V_MEM * V_CPU
SYNC_TYPE = "rsync" # how to sync files in vagrant, for lxc rsync is suggested

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  #########################################################################
  # Global config section
  #########################################################################


  # fix for bash errors while provisioning
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  # Every Vagrant virtual environment requires a box to build
  config.vm.box = 'centos/7'

  # puppet stuff and provisioning
  config.vm.synced_folder "./vagrant", "/vagrant",
    id: "vagrant",
    type: SYNC_TYPE,
    # rsync__verbose: true,
    rsync__exclude: [".git/", "puppet/.tmp/"]

  # test suites
  config.vm.synced_folder "./test", "/tmp/test",
    id: "test",
    type: SYNC_TYPE,
    rsync__exclude: ".git/"


  #########################################################################
  # VM Providers
  #########################################################################

  # default, Virtualbox
  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--cpus', V_CPU]
    v.customize ['modifyvm', :id, '--memory', V_MEM_TOTAL]
  end

  # LXC under linux
  config.vm.provider :lxc do |l, override|
    override.vm.box = "st01tkh/centos7-64-lxc"
  end

  # QEMU/KVM under linux
  config.vm.provider :kvm do |kvm|
    kvm.vm.box = "centos7lxc"
    kvm.core_number = V_CPU
    kvm.memory_size = "#{V_MEM_TOTAL}MiB" # leave doublequotes
    #config.vm.synced_folder ".", "/vagrant", type: "nfs"
  end

  # QEMU/KVM via libVirt
  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus   = V_CPU
    libvirt.memory = V_MEM_TOTAL
    libvirt.driver = 'kvm'
    libvirt.disk_bus = 'virtio'
    libvirt.volume_cache = 'unsafe' # warning, use only on computers with battery, posssible data loss
  end

  #########################################################################
  # Provisioners
  #########################################################################

  # installs puppet and its dependencies
  config.vm.provision "bootstrap",
    type: 'shell',
    :path => 'vagrant/bootstrap.sh'

  #########################################################################
  # VM definitions
  #########################################################################


  config.vm.define :app do |v|

    # expand synced folders with our app
    v.vm.synced_folder "./src", "/srv/app",
      id: "app",
      type: SYNC_TYPE,
      rsync__exclude: ".git/"

    v.vm.network "forwarded_port", guest: 80, host: 8183
    v.vm.network "forwarded_port", guest: 2812, host: 12812
    v.vm.network "forwarded_port", guest: 9090, host: 19090

    # LXC overrides to have the same ip and hostname
    v.vm.provider :lxc do |lxc|
      lxc.customize "network.hwaddr", "00:16:3e:33:44:49"
      lxc.container_name = :machine
      lxc.customize "aa_allow_incomplete", "1"
      lxc.customize "cgroup.cpuset.cpus", "0,1"  # two cores
      lxc.customize "cgroup.memory.limit_in_bytes", "#{V_MEM_TOTAL}M"
    end

    # libvirt overrides, same hostname
    v.vm.provider :libvirt do |libvirt, override|
      override.vm.hostname = "app"
    end

    v.vm.provision "facter",
      type: "shell",
      path: "vagrant/facter.sh",
      preserve_order: true,
      args: [
        "role=#{:app}", # equals role=app
        "vagrant=1",
      ]

    # downloads puppet modules from forge
    v.vm.provision "librarian",
      type: "shell",
      path: "vagrant/librarian-puppet.sh",
      preserve_order: true,
      args: ['/vagrant/puppet']

    # after librarian is done, we can run puppet apply
    v.vm.provision "puppet",
      type: "shell",
      path: "vagrant/puppet-apply.sh",
      preserve_order: true,
      env: {
        PUPPET_DIR: '/vagrant/puppet', # corresponds to rsynced folder
        # PUPPET_ENVIRONMENT: "production",
        # PUPPET_HIERA_CONFIG: "hiera.yaml",
        # PUPPET_MANIFEST: "default.pp",
        # PUPPET_MANIFST_DIR: "manifests/",
        PUPPET_MODULEPATH: "modules:local_modules",
        PUPPET_OPTS: "--graph --graphdir /vagrant/graphs",
        PUPPET_VERBOSE: "1",
      }

    # print some final informations
    v.vm.provision "info",
      type: "shell",
      path: "vagrant/info.sh",
      preserve_order: true

  end

end
