# include base classes
# some fixes for containers etc

class profile::base {

  case $::virtual{
    'lxc', 'docker': {
      notice('Skipping applying changes on LXC')
    }

    default: {
      include ::ntp
    }
  }

}