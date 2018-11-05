# encoding: utf-8

require 'spec_helper'

sys_packages = [
  'python36u',
  'python2-pip',
  'python36u-pip',
  'python-devel',
  'python36u-devel'
]

sys_packages.each do |yum_package|
  describe package(yum_package) do
    it { should be_installed }
  end
end

describe command('which virtualenv') do
  its(:stdout) { should match(/virtualenv/) }
end

# for some reason python 2 --version outputs to stderr
describe command('python -V') do
  its(:stderr) { should match(/Python 2/) }
end

describe command('/tmp/py3project/venv/bin/python -V') do
  its(:stdout) { should match(/Python 3.6/) }
end

describe command("/tmp/py3project/venv/bin/python -c 'import sys; print(sys.path)'") do
  its(:stdout) { should match(%r{/tmp/py3project/venv/lib/python3.6/site-packages}) }
end

describe file('/tmp/py3project/libs/pip-10.0.1.dist-info/') do
  it { should be_directory }
end

describe file('/tmp/py3project/libs/requests/') do
  it { should be_directory }
end

describe file('/tmp/py3project/updated-requirements.txt') do
  its(:content) { should match(/requests==/) }
end

describe file('/tmp/py3project/testfile.out') do
  its(:content) { should match(/foo:bar/) }
end
