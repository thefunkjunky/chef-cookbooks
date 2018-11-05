# Encoding: utf-8
require 'spec_helper'

jenkins_home = '/var/lib/jenkins'
plugins_home = "#{jenkins_home}/plugins"

describe package('jenkins') do
  it { should be_installed }
end

# Plugins need to be installed, yeah?
%w(git
   github
   github-api
   scm-api
   slack).each do |plugins|
  describe file("#{plugins_home}/#{plugins}.hpi") do
    it { should exist }
  end
  describe file("#{plugins_home}/#{plugins}") do
    it { should be_directory }
  end
end

# Jenkins takes a while to warm up after converge
sleep(30)
# Health check using Metrics plugin
# Note that key must match the one in attributes/default.rb
describe command('curl -X GET http://localhost:8080/metrics/'\
  'vwipjJrw0rrK6xVvLutC8jUqw9JEHZepwbRuyIZRCkLLPsSiR9XR3u4BnHpU9v2W/healthcheck '\
  '--verbose --max-time 90 --connect-timeout 90') do
  its(:stderr) { should contain('HTTP/1.1 200 OK') }
  its(:stdout_as_json) { should include('plugins' => include('message' => 'No failed plugins')) }
end
