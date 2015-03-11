require "active_support/concern"
require "serial_spec/version"
require "serial_spec/it_expects"
require "serial_spec/parsed_body"
require "serial_spec/request_response"
require "inheritable_accessors"

module SerialSpec
  extend ActiveSupport::Concern
  include ItExpects
  include RequestResponse
  include ParsedBody

  module ClassMethods

    def with_request(request_str, params={}, envs={}, &block)
      raise ArgumentError, "must format first argument like 'GET /messages'" unless request_str.split(/\s+/).count == 2
      request_method_string, request_path_str = request_str.split(/\s+/)

      context_klass = context "with request: '#{request_str}'" do
        request_method request_method_string
        request_path   request_path_str

        if block_given?
          instance_exec(&block)
        else
          it "should match all examples: #{__inherited_expectations__.keys}" do
            perform_request!
          end
        end

      end

    end

  end

end
