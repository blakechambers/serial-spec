$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../support', __FILE__)
require 'serial_spec'

if defined?(BSON)
  module BSON
    class ObjectId
      def as_json(opts=nil)
        to_s
      end
      alias :to_json :as_json
    end
  end
end


if defined?(ActiveModel::Serializer)
  require 'fake_models'
end

require 'rack/test'
