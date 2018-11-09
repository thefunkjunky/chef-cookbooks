#
# Cookbook Name:: chef_jenkins
# Recipe:: ghe_repo_settings
#
# Copyright 2018, Consensus Corp
#
# All rights reserved - Do Not Redistribute
#

pip_packages = {
  'requests' => '',
  'virtualenv' => ''
}

directory '/opt/ghe-repo-settings' do
  mode '0750'
end

cookbook_file '/opt/ghe-repo-settings/set-repo-settings.py' do
  source 'set-repo-settings.py'
  action :create
  mode '0640'
end

py_virtualenv '/opt/ghe-repo-settings/venv' do
  py_binary 'python'
end

py_packages 'branch protection pip packages' do
  pip_location '/opt/ghe-repo-settings/venv/bin/pip'
  packages pip_packages
end

node['chef_jenkins']['pipelines'].each do |pipeline|
  branch_protection_args = [
    "--ghe_api=\"#{node['chef_jenkins']['github']['endpoint']}\"",
    "--org=#{pipeline['ghe_org']}",
    "--token=#{node.run_state['jenkins_secrets']['ghe_token']}"
  ]

  py_run '/opt/ghe-repo-settings/set-repo-settings.py' do
    py_binary '/opt/ghe-repo-settings/venv/bin/python'
    script_args branch_protection_args
  end
end
