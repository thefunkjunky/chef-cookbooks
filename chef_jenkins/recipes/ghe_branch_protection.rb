#
# Cookbook Name:: chef_jenkins
# Recipe:: ghe_branch_protection
#
#

pip_packages = {
  'requests' => '',
  'virtualenv' => ''
}

directory '/opt/ghe-branch-protections' do
  mode '0750'
end

cookbook_file '/opt/ghe-branch-protections/set-branch-protections.py' do
  source 'set-branch-protections.py'
  action :create
  mode '0640'
end

py_virtualenv '/opt/ghe-branch-protections/venv' do
  py_binary 'python'
end

py_packages 'branch protection pip packages' do
  pip_location '/opt/ghe-branch-protections/venv/bin/pip'
  packages pip_packages
end

node['chef_jenkins']['pipelines'].each do |pipeline|
  branch_protection_args = [
    "--ghe_api=\"#{node['chef_jenkins']['github']['endpoint']}\"",
    "--org=#{pipeline['ghe_org']}",
    "--token=#{node.run_state['jenkins_secrets']['ghe_token']}"
  ]

  py_run '/opt/ghe-branch-protections/set-branch-protections.py' do
    py_binary '/opt/ghe-branch-protections/venv/bin/python'
    script_args branch_protection_args
  end
end
