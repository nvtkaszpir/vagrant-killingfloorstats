
class profile::app (
  $dir = '/srv/app',
  $domain = 'kfstats.hlds.pl',
) {

  include ::nginx

  class {'::php::globals': }
  ->
  class {'::php': }

  file { $dir:
    ensure  => 'directory',
    recurse => true,
    mode    => '0755',
    owner   => 'nobody',
    group   => 'nobody',
    seltype => 'httpd_sys_content_t', # read only app
  }
}
