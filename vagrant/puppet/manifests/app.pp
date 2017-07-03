node default {
  notice("Role ${::role}")
  notice("Virtual ${::virtual}")

  include ::role::app

}

