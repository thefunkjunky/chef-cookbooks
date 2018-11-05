#
# Cookbook Name:: chef_jenkins
# Recipe:: base
#
#

# Placeholder for recipe to install/setup Chef dev stuff

directory "#{node['jenkins']['master']['home']}/.chef" do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode 0755
end

# Let's get the chef and ssh keys
file "#{node['jenkins']['master']['home']}/.chef/chef-pipeline.pem" do
  content node.run_state['jenkins_secrets']['chef_key']
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode 0600
  sensitive true
end

cookbook_file "#{node['jenkins']['master']['home']}/.chef/knife.rb" do
  source 'knife.rb'
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode 0600
  action :create_if_missing
end

directory "#{node['jenkins']['master']['home']}/.ssh" do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode 0700
end

file "#{node['jenkins']['master']['home']}/.ssh/id_rsa" do
  content node.run_state['jenkins_secrets']['ssh_key']
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode 0600
  sensitive true
end

cookbook_file "#{node['jenkins']['master']['home']}/.ssh/known_hosts" do
  source 'known_hosts'
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode 0600
  action :create_if_missing
end

template "#{node['jenkins']['master']['home']}/.user_config.tk" do
  source 'user_config.tk.erb'
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode 0600
end
