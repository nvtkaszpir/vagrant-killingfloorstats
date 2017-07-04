# encoding: utf-8

# pretty dumb, also this is controlled via systemd
title 'cockpit'
# TODO: parametrize as attributes
cockpit_path       = '/etc/cockpit'
cockpit_conf       = File.join(cockpit_path, 'cockpit.conf')

control 'cockpit-service' do
  impact 1.0
  title 'Check cockpit service files'
  desc 'cockpit service should be enabled and running'

  describe service('cockpit') do
    it { should be_enabled }
    it { should be_running }
  end
end

