$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../support', __FILE__)
require 'pry'
require 'serial_spec'

if defined?(ActiveModel::Serializer)
  require 'fake_models'
end

require 'rack/test'
