#
# Cookbook Name:: chef_jenkins
# Recipe:: secrets
#
#

directory node['chef_jenkins']['secrets']['path'] do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['user']
  mode 0700
end

# This is the key for supermarket's necrypted databag
s3_file "#{node['chef_jenkins']['secrets']['path']}/supermarket_data_bag_secret" do
  remote_path 'chef/supermarket_data_bag_secret'
  bucket 'securebucket'
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['user']
  mode 0600
end

secret_file_name = 'chef_jenkins_data_bag_secret'
bag_secret = "/etc/chef/#{secret_file_name}"
s3_file bag_secret do
  remote_path "chef/#{secret_file_name}"
  bucket 'securebucket'
  mode '600'
end.run_action(:create)

secret = Chef::EncryptedDataBagItem.load_secret(bag_secret)
node.run_state['jenkins_secrets'] = data_bag_item('jenkins_databag', 'secrets', secret)
