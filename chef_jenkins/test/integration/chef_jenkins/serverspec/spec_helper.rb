# Encoding: utf-8

require 'serverspec'

RSpec.configure do |config|
  config.order = 'random'
end

set :backend, :exec
set :path, '$PATH:/sbin'
