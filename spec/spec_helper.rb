$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../support', __FILE__)
require 'serial_spec'
module BSON
  class ObjectId
    alias :to_json :to_s
    alias :as_json :to_s
  end
end
if defined?(ActiveModel::Serializer)
  require 'fake_models'
end

require 'rack/test'
