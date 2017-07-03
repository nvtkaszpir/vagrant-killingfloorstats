# broken due to php and collectd dependency
# voxpopuli-php depends on example42-yum which conflicts with official yum package
node default {

  include ::role::monitoring


}

