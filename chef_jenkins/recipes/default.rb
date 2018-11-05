#
# Cookbook Name:: chef_jenkins
# Recipe:: default
#
# Copyright 2018, Consensus Corp
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'chef_python::default'
include_recipe 'chef_jenkins::packages'
include_recipe 'chef_jenkins::secrets'
include_recipe 'chef_jenkins::config'
include_recipe 'chef_jenkins::ghe_branch_protection'
