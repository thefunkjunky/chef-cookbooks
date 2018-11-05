#
# Cookbook Name:: chef_jenkins
# Recipe:: config
#

jenkins_home = node['jenkins']['master']['home']

group 'jenkins' do
  action :create
end

user 'jenkins' do
  group 'jenkins'
  shell '/bin/bash'
  home '/var/lib/jenkins'
end

directory jenkins_home do
  owner     node['jenkins']['master']['user']
  group     node['jenkins']['master']['group']
  mode      '0750'
  recursive true
end

# Create the log directory
directory node['jenkins']['master']['log_directory'] do
  owner     node['jenkins']['master']['user']
  group     node['jenkins']['master']['group']
  mode      '0750'
  recursive true
end

# Create/fix permissions on supplemental directories
%w(cache lib run).each do |folder|
  directory "/var/#{folder}/jenkins" do
    owner node['jenkins']['master']['user']
    group node['jenkins']['master']['group']
    mode '0750'
    action :create
  end
end

template '/etc/sysconfig/jenkins' do
  source   'jenkins-config-rhel.erb'
  mode     '0640'
  notifies :restart, 'service[jenkins]', :immediately
end

# Base Chef configuration
include_recipe 'chef_jenkins::base'

# Installs Plug-ins
include_recipe 'chef_jenkins::plugins'

# Adds credentials to Jenkins.
# Note that certain plugins will only accept user/pass or secret text credentials,
# so both are being created here.
jenkins_password_credentials node['chef_jenkins']['github']['credentials']['name'] do
  id "#{node['chef_jenkins']['github']['credentials']['name']}-userpass"
  description 'Consensus DevOps Jenkins GHE user/pass'
  password node.run_state['jenkins_secrets']['ghe_token']
end

jenkins_secret_text_credentials node['chef_jenkins']['github']['credentials']['name'] do
  id "#{node['chef_jenkins']['github']['credentials']['name']}-text"
  description 'Consensus DevOps Jenkins GHE secret text'
  secret node.run_state['jenkins_secrets']['ghe_token']
end

jenkins_secret_text_credentials node['chef_jenkins']['slack']['id'] do
  id node['chef_jenkins']['slack']['id']
  description 'Consensus Jenkins Slack notifications credentials'
  secret node.run_state['jenkins_secrets']['slack_secret']
end

# Configures admin email address and URL of jenkins server
template "#{jenkins_home}/jenkins.model.JenkinsLocationConfiguration.xml" do
  source 'jenkins.model.JenkinsLocationConfiguration.xml.erb'
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode 0640
  notifies :execute, 'jenkins_command[safe-restart]', :immediately
end

# Configures Jenkins parameters - num executors, descriptions
template "#{jenkins_home}/config.xml" do
  source 'config.xml.erb'
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  mode 0644
  action :create_if_missing
  notifies :execute, 'jenkins_command[safe-restart]', :immediately
end

# Configure Plugins
template "#{jenkins_home}/github-plugin-configuration.xml" do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  source 'github-plugin-configuration.xml.erb'
  mode 0640
  notifies :execute, 'jenkins_command[safe-restart]'
end

template "#{jenkins_home}/org.jenkinsci.plugins.github_branch_source.GitHubConfiguration.xml" do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  source 'org.jenkinsci.plugins.github_branch_source.GitHubConfiguration.xml.erb'
  mode 0640
  notifies :execute, 'jenkins_command[safe-restart]'
end

template "#{jenkins_home}/jenkins.plugins.slack.SlackNotifier.xml" do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  source 'jenkins.plugins.slack.SlackNotifier.xml.erb'
  mode 0640
  notifies :execute, 'jenkins_command[safe-restart]'
end

template "#{jenkins_home}/jenkins.metrics.api.MetricsAccessKey.xml" do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  source 'jenkins.metrics.api.MetricsAccessKey.xml.erb'
  mode 0640
  notifies :execute, 'jenkins_command[safe-restart]'
end

template "#{jenkins_home}/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml" do
  owner node['jenkins']['master']['user']
  group node['jenkins']['master']['group']
  source 'org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml.erb'
  mode 0640
  notifies :execute, 'jenkins_command[safe-restart]'
end

# Config organization jobs
node['chef_jenkins']['pipelines'].each do |pipeline|
  org_job_dir = "#{jenkins_home}/jobs/#{pipeline['ghe_org']}"
  directory org_job_dir do
    owner     node['jenkins']['master']['user']
    group     node['jenkins']['master']['group']
    mode      0750
    recursive true
  end

  template "#{org_job_dir}/config.xml" do
    owner node['jenkins']['master']['user']
    group node['jenkins']['master']['group']
    source 'org_job_config.xml.erb'
    mode 0640
    notifies :execute, 'jenkins_command[safe-restart]'
    variables(
      ghe_org: pipeline['ghe_org'],
      credentials_name: pipeline['credentials_name'],
      max_item_age: pipeline['max_item_age'],
      polling: pipeline['polling']
    )
  end
end
