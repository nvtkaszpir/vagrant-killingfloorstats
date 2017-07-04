# encoding: utf-8


title 'Monit'
# TODO: parametrize as attributes
monit_version    = '5.14'
monit_path       = '/etc/'
monit_conf       = File.join(monit_path, 'monitrc')
monit_listen     = ['0.0.0.0']
monit_listen_t   = ['tcp']
monit_listen_p   = 2812
monit_listen_pr  = ['monit']

control 'monit-service' do
  impact 1.0
  title 'Check monit service files'
  desc 'monit service should be enabled and running'

  describe service('monit') do
    it { should be_enabled }
    it { should be_running }
  end
end

control 'monit-config-syntax' do
  impact 1.0
  title 'Check monit confg files'
  desc 'monit config should be valid'

  describe command('monit -t') do
    its('stdout') { should match 'Control file syntax OK' }
  end
end

control 'monit-service-port' do
  impact 1.0
  title 'monit service should be listening on specified port'
  desc 'monit service should be listening on specified port'

  describe port(monit_listen_p) do
    it { should be_listening }
    its('protocols') { should eq monit_listen_t }
    its('addresses') { should eq monit_listen }
    its('processes') { should eq monit_listen_pr }
  end

end