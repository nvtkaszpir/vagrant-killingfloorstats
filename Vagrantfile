# -*- mode: ruby -*-
# vi: set ft=ruby :
#ENV['VAGRANT_DEFAULT_PROVIDER'] = 'lxc'
V_CPU = 2 # in cores
V_MEM = 512 # in megabytes per core
V_MEM_TOTAL = V_MEM * V_CPU
SYNC_TYPE = "rsync" # how to sync files in vagrant, for lxc rsync is suggested

unless Vagrant.has_plugin?("vagrant-librarian-puppet")
  raise 'vagrant-librarian-puppet is not installed! Please install it via "vagrant plugin install vagrant-librarian-puppet".'
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  #########################################################################
  # Global config section
  #########################################################################


  # fix for bash errors while provisioning
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = 'centos/7'


  # application ports
  # puppet stuff and provisioning
  config.vm.synced_folder "./vagrant", "/vagrant",
    type: SYNC_TYPE,
    # rsync__verbose: true,
    rsync__exclude: [".git/", "puppet/.tmp/"]


  #########################################################################
  # VM Providers
  #########################################################################

  # default, Virtualbox
  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--cpus', V_CPU]
    v.customize ['modifyvm', :id, '--memory', V_MEM_TOTAL]
  end

  # LXC under linux
  config.vm.provider :lxc do |lxc|
   lxc.customize 'cgroup.cpuset.cpus', '0,1'  # two cores
   lxc.customize 'cgroup.memory.limit_in_bytes', "#{V_MEM_TOTAL}M"
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

  config.vm.provision 'shell', :path => 'vagrant/bootstrap.sh'

  # The librarian-puppet plugin works in this dir.
  config.librarian_puppet.puppetfile_dir = "vagrant/puppet"
  config.librarian_puppet.placeholder_filename = ".gitkeep"
  # The librarian-puppet module installs all 3rd party modules to puppet/modules
  # We develop our modules in puppet/local_modules

  # notice, below we define puppet settings per vm, and just facter section differs

  #########################################################################
  # VM definitions
  #########################################################################


  config.vm.define :app do |v|

    v.vm.network "forwarded_port", guest: 80, host: 8183
    v.vm.network "forwarded_port", guest: 2812, host: 12812
    v.vm.network "forwarded_port", guest: 9090, host: 19090

    # LXC overrides to have the same ip and hostname
    v.vm.provider :lxc do |lxc|
      lxc.customize "network.hwaddr", "00:16:3e:33:44:49"
      lxc.container_name = :machine
    end

    # libvirt overrides, same hostname
    v.vm.provider :libvirt do |libvirt, override|
      override.vm.hostname = "app"
    end

    v.vm.provision "shell", inline: <<-SHELL
      mkdir -p /etc/facter/facts.d/
      echo "role=app" > /etc/facter/facts.d/vagrant.txt
    SHELL

    v.vm.provision "puppet" do |puppet|
      puppet.manifest_file      = "app.pp"
      puppet.facter = {
        "vagrant" => 1,
        "role"    => "app"
      }
      puppet.synced_folder_type = SYNC_TYPE
      puppet.manifests_path     = "vagrant/puppet/manifests"
      puppet.module_path        = ["vagrant/puppet/modules", "vagrant/puppet/local_modules"]
      puppet.hiera_config_path  = "vagrant/puppet/hiera.yaml"
      puppet.working_directory  = "/tmp/vagrant-puppet"
      puppet.options = [
        '--graph',
        '--graphdir /vagrant/graphs',
        '--verbose',
        # '--debug',
      ]


    end

    # expand synced folders with our app
    v.vm.synced_folder "./src", "/srv/app",
      type: SYNC_TYPE,
      rsync__exclude: ".git/"

  end


  # config.vm.define :monitoring do |v|
  #
  #   v.vm.network "forwarded_port", guest: 80, host: 8184
  #
  #   v.vm.provider :lxc do |lxc|
  #     lxc.customize "network.hwaddr", "00:16:3e:33:44:50"
  #     lxc.container_name = :machine
  #   end
  #
  #   v.vm.provision "puppet" do |puppet|
  #     puppet.manifest_file      = "monitoring.pp"
  #     puppet.facter = {
  #       "vagrant" => 1,
  #       "role" => "monitoring",
  #     }
  #     puppet.synced_folder_type = SYNC_TYPE
  #     puppet.manifests_path     = "vagrant/puppet/manifests"
  #     puppet.module_path        = ["vagrant/puppet/modules", "vagrant/puppet/local_modules"]
  #     puppet.hiera_config_path  = "vagrant/puppet/hiera.yaml"
  #     puppet.working_directory  = "/tmp/vagrant-puppet"
  #     puppet.options = [
  #       '--graph',
  #       '--graphdir /vagrant/graphs',
  #       '--verbose',
  #       # '--debug',
  #     ]
  #
  #
  #   end
  #
  # end



end
