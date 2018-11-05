#
# Cookbook Name:: chef_jenkins
# Recipe:: plugins
#
#

require 'json'

plugins_manifest = "#{node['chef_jenkins']['jenkins']['plugins_dir']}/manifest.json"

directory '/opt/jenkins-plugin-installer' do
  mode '0750'
end

# Install Jenkins plugins
cookbook_file '/opt/jenkins-plugin-installer/install-jenkins-plugins.py' do
  source 'install-jenkins-plugins.py'
  action :create
  mode '0640'
end

cookbook_file '/opt/jenkins-plugin-installer/plugins.json' do
  source 'plugins.json'
  mode '0640'
  action :create
end

py_run '/opt/jenkins-plugin-installer/install-jenkins-plugins.py' do
  script_args [
    '--plugins_json=/opt/jenkins-plugin-installer/plugins.json',
    "--plugins_dir=#{node['chef_jenkins']['jenkins']['plugins_dir']}",
    "--manifest=#{plugins_manifest}"
  ]
end

execute 'Restart Jenkins if new plugins installed' do
  command 'echo "Restarting Jenkins"'
  notifies :execute, 'jenkins_command[safe-restart]', :immediately
  only_if { ::File.readlines('/opt/jenkins-plugin-installer/last_action.log').grep(/No/i).empty? }
end
