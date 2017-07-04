
class profile::monit {

  include ::monit


  # ok, this is pretty lame, we use cockpit to generate self-signed cert
  # to be later used in monit :)
  include ::cockpit

  # make sure self-signed cert permissions are properly set
  file {'/etc/cockpit/ws-certs.d/0-self-signed.cert':
    ensure  => present,
    mode    => '0600',
    require => Class['::cockpit'],
    before  => Class['::monit::service'],
  }

}
