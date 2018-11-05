# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                'chef-pipeline'
client_key               "#{current_dir}/chef-pipeline.pem"
chef_server_url          'https://chefserver.mydomain.com/organizations/chef'
cookbook_path            ["#{current_dir}/../cookbooks"]
knife[:supermarket_site] = 'https://supermarket.mydomain.com'
