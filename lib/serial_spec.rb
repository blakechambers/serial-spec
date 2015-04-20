require "active_support/concern"
require "serial_spec/version"
require "serial_spec/it_expects"
require "serial_spec/parsed_body"
require "serial_spec/request_response"
require "inheritable_accessors"
begin
  require 'active_model_serializers'
  require 'bson'
rescue LoadError
end

module SerialSpec
  extend ActiveSupport::Concern
  include ItExpects
  include RequestResponse
  include RequestResponse::Helpers
  if defined?(ActiveModel::Serializer)
    require "serial_spec/request_response/provide_matcher"
    include RequestResponse::ProvideMatcher
  end

  SERIAL_VALID_VERBS = %w{GET POST PUT PATCH DELETE OPTIONS HEAD}

  module ClassMethods

    def with_request(request_str, params={}, envs={}, &block)
      if request_str.split(/\s+/).count == 2
        request_method_string, request_path_str = request_str.split(/\s+/)
      end

      context_klass = context "with request: '#{request_str}'" do
        if request_str.split(/\s+/).count == 2
          request_method_string, request_path_str = request_str.split(/\s+/)
          if SERIAL_VALID_VERBS.include?(request_method_string)
            # Prefer preference to blocks, chances are the blocks need to be
            # executed at a lower level
            unless request_opts[:request_method] and request_opts[:request_method].instance_of?(InheritableAccessors::InheritableOptionAccessor::LetOption)
              request_method request_method_string
            end

            unless request_opts[:request_path] and request_opts[:request_path].instance_of?(InheritableAccessors::InheritableOptionAccessor::LetOption)
              request_path   request_path_str
            end
          end
        end

        instance_exec(&block) if block_given?

        it "should match all examples: #{__inherited_expectations__.keys}" do
          perform_request!
        end

      end

    end

  end
end
