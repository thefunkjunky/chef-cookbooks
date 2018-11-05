# Load plugins manifest into attriubte
require 'json'
plugins_json = File.read(File.dirname(
  File.expand_path(__FILE__)) + '/../files/default/plugins.json')
default['chef_jenkins']['plugins'] = JSON.parse(plugins_json)

# Pipelines json
default['chef_jenkins']['pipelines_json'] = '/../files/default/pipelines.json'
pipelines_json = File.read(File.dirname(
  File.expand_path(__FILE__)) + node['chef_jenkins']['pipelines_json'])
default['chef_jenkins']['pipelines'] = JSON.parse(pipelines_json)

# Check if any duplicate values
ghe_orgs = []
shared_pipeline_names = []
shared_pipeline_ids = []
node['chef_jenkins']['pipelines'].each do |pipeline|
  ghe_orgs << pipeline['ghe_org']
  shared_pipeline_names << pipeline['shared_pipeline_name']
  shared_pipeline_ids << pipeline['shared_pipeline_id']
end
raise 'Duplicate GHE Orgs' if ghe_orgs.length > ghe_orgs.uniq.length
raise 'Duplicate Shared Pipeline Library Names' if shared_pipeline_names.length > shared_pipeline_names.uniq.length
raise 'Duplicate Shared Pipeline Library Ids' if shared_pipeline_ids.length > shared_pipeline_ids.uniq.length

# wrapped cookbook attribute overrides
default['jenkins']['master']['version'] = '2.138.1-1.1'
default['jenkins']['executor']['timeout'] = 240
default['jenkins']['master']['port'] = 8080

# JRE package
default['chef_jenkins']['jre']['package'] = 'jdk'
default['chef_jenkins']['jre']['version'] = '1.7.0_80-fcs'

# Mail settings
default['cdo_chefbuild']['email']['reply_to'] = 'whatever@whatever.com'

# We interact with AWS using these keys
default['chef_jenkins']['pipeline']['aws']['key_pair'] = 'whatever'

# Basic Jenkins configuration
default['jenkins']['master']['home'] = '/var/lib/jenkins'
default['chef_jenkins']['jenkins']['plugins_dir'] = '/var/lib/jenkins/plugins'
default['chef_jenkins']['jenkins']['num_executors'] = 5
default['chef_jenkins']['jenkins']['max_item_age'] = 90

# Plugins configuration
# Github
default['chef_jenkins']['github']['server'] = 'www.github.com'
default['chef_jenkins']['github']['endpoint'] = "https://#{node['chef_jenkins']['github']['server']}/api/v3"
default['chef_jenkins']['github']['credentials']['name'] = 'github-creds'

# Slack
default['chef_jenkins']['slack']['webhook'] = 'https://hooks.slack.com/services/ABCD1234'
default['chef_jenkins']['slack']['id'] = 'slack-id'

# Metrics
default['chef_jenkins']['metrics_key'] = 'vwipjJrw0rrK6xVvLutC8jUqw9JEHZepwbRuyIZRCkLLPsSiR9XR3u4BnHpU9v2W'

# URL for Jenkins.  Don't forget the trailing slash!
default['chef_jenkins']['jenkins']['url'] = 'https://jenkins.myserver.com/'
default['chef_jenkins']['secrets']['path'] = "#{node['jenkins']['master']['home']}/.secrets"

# Chef-client settings
default['chef_client']['interval'] = '1800'
default['chef_client']['splay'] = '300'
