
class role::app {

  include ::profile
  include ::profile::monit
  include ::profile::app

}
