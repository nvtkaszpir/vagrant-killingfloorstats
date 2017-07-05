# include base classes
# some fixes for containers etc

class profile::base {

  case $::virtual{
    'lxc', 'docker': {
      notice('Skipping applying changes on LXC')
      # there is no point in including certain classes like ntp
    }

    default: {
      include ::ntp
    }
  }

}