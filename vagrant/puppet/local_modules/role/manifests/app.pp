
class role::app {

  include ::profile
  include ::profile::monit
  include ::profile::cockpit
  include ::profile::app

}
