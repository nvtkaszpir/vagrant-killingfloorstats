# cert should be a contents of the certificate
class profile::monit (
  $cert
) {

  include ::epel
  include ::monit

  Class['epel'] -> Class['monit::install']

  # make sure self-signed cert permissions are properly set
  file {'/etc/ssl/monit.pem':
    ensure  => present,
    mode    => '0600',
    before  => Class['monit::service'],
    content => $cert,
  }

}
