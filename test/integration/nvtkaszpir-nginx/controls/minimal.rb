# encoding: utf-8


title 'Nginx'
# TODO: parametrize as attributes
nginx_version    = '1.10'
nginx_path       = '/etc/nginx'
nginx_conf       = File.join(nginx_path, 'nginx.cfg')

control 'nginx-service' do
  impact 1.0
  title 'Check nginx service files'
  desc 'nginx service should be enabled and running'

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end
end

control 'nginx-config-syntax' do
  impact 1.0
  title 'Check nginx confg files'
  desc 'nginx config should be valid'

  describe command('nginx -t') do
    its('stderr') { should match 'syntax is ok' }
    its('stderr') { should match 'test is successful' }
  end
end
