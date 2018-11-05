#
# Cookbook Name:: chef_jenkins
# Recipe:: packages
#

package node['chef_jenkins']['jre']['package'] do
  version node['chef_jenkins']['jre']['version']
end

pip_packages = {
  'pip' => '==18.1',
  'awscli' => '==1.16.39'
}

py_packages 'pip and awscli' do
  packages pip_packages
  pip_install_options ['--upgrade']
end

package 'jenkins' do
  version node['jenkins']['master']['version']
end

service 'jenkins' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

jenkins_command 'safe-restart' do
  action :nothing
end
