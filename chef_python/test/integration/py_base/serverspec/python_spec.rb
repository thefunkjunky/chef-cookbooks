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
