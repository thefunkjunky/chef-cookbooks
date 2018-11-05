#
# Cookbook Name:: chef_python
# Recipe:: py_tests
#

include_recipe 'chef_python::default'

py_virtualenv '/tmp/py3project/venv' do
  py_binary 'python3.6'
end

cookbook_file '/tmp/py3project/requirements.txt' do
  source 'test_requirements.txt'
end

additional_packages = { 'pip' => '==10.0.1' }

py_packages 'py3 packages' do
  pip_location '/tmp/py3project/venv/bin/pip'
  requirements_txt 'tmp/py3project/requirements.txt'
  packages additional_packages
  pip_install_options ['--upgrade']
end

py_packages 'py3 packages' do
  pip_location '/tmp/py3project/venv/bin/pip'
  requirements_txt 'tmp/py3project/requirements.txt'
  packages additional_packages
  target_folder '/tmp/py3project/libs'
  pip_install_options ['--upgrade']
end

py_packages 'freeze new requirements' do
  pip_location '/tmp/py3project/venv/bin/pip'
  pip_freeze_file '/tmp/py3project/updated-requirements.txt'
  action :pip_freeze
end

cookbook_file '/tmp/py3project/libs/mylib.py' do
  source 'mylib.py'
end

cookbook_file '/tmp/py3project/runthis.py' do
  source 'runthis.py'
end

py_run '/tmp/py3project/runthis.py' do
  py_binary '/tmp/py3project/venv/bin/python'
  pythonpath '/tmp/py3project/libs/'
  script_args ['bar']
end
