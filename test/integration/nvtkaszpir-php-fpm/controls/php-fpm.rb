# encoding: utf-8


title 'php-fpm listening on TCP port'

php_version = '5.6'
php_listen     = ['127.0.0.1']
php_listen_t   = ['tcp']
php_listen_p   = 9000
php_listen_pr  = ['php-fpm']

control 'php-fpm-package' do
  impact 1.0
  title 'php-fpm should be availabe'
  desc 'php-fpm should be availabe'

  describe package('php-fpm') do
   it { should be_installed }
   its('version') { should match(php_version) }
  end

end

control 'php-fpm-config' do
  impact 1.0
  title 'php-fpm config test should be succesful'
  desc 'php-fpm config test should be succesful'

  describe command('php-fpm -t') do
   its('stderr') { should match ('test is successful') }
  end

end

control 'php-fpm-service' do
  impact 1.0
  title 'php-fpm service should be running and enabled'
  desc 'php-fpm service should be running and enabled'

  describe service('php-fpm') do
   it { should be_enabled }
   it { should be_running }
  end

end

control 'php-fpm-service-port' do
  impact 1.0
  title 'php-fpm service should be listening on specified port'
  desc 'php-fpm service should be listening on specified port'

  describe port(php_listen_p) do
    it { should be_listening }
    its('protocols') { should eq php_listen_t }
    its('addresses') { should eq php_listen }
    its('processes') { should eq php_listen_pr }
  end

end

