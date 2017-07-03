# InSpec Profile

Checks for basic settings for PHP5.6 in FPM mode, tailored for Centos 7.3.
This was not tested with any other distribution.

Executing test with inspec:

```bash
inspec exec test/integration/inspec/nvtkaszpir-php5-fpm-5.6 -t ssh://192.168.121.242:22 --user=vagrant --key-files=.vagrant/machines/app/libvirt/private_key --sudo --profiles-path=test/integration/inspec/

```
