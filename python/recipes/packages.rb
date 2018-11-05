#
# Cookbook Name:: chef_python
# Recipe:: packages
#
#

node['chef_python']['py_sys_packages'].each do |py_sys_package|
  package py_sys_package
end
