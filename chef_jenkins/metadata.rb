name             'chef_jenkins'
maintainer       'Garrett Anderson'
maintainer_email 'nonofyalls@business.com'
license          'MIT License'
description      'Installs/Configures Jenkins as part of a pipeline'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url       'https://www.github.com/thefunkjunky/chef-cookbooks/chef-jenkins'
issues_url       'https://www.github.com/thefunkjunky/chef-cookbooks/issues'
version          '0.1.0'

depends 'chef_python'
depends 'jenkins', '= 6.2.0'
