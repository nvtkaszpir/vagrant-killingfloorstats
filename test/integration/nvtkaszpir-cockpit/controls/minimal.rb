# encoding: utf-8

# pretty dumb, also this is controlled via systemd
title 'cockpit'
# TODO: parametrize as attributes
cockpit_path       = '/etc/cockpit'
cockpit_conf       = File.join(cockpit_path, 'cockpit.conf')
cockpit_listen_p   = 9090
cockpit_listen_t   = ['tcp6']
cockpit_listen_pr  = ['systemd']

control 'cockpit-service' do
  impact 1.0
  title 'Check cockpit service files'
  desc 'cockpit service should be enabled'

  describe service('cockpit') do
    it { should be_enabled }
  end
end


control 'cockpit-port' do
  impact 1.0
  title 'Check cockpit service port (via systemd)'
  desc 'cockpit service should be listening on default port'

  describe port(cockpit_listen_p) do
    it { should be_listening }
    its('protocols') { should eq cockpit_listen_t }
    its('processes') { should eq cockpit_listen_pr }
  end
end
