require 'json'
require 'serial_spec/parsed_body'

module SerialSpec
  module RequestResponse
    module Helpers
      extend ActiveSupport::Concern

      def status
        response.status
      end

      def headers
        response.headers
      end

      def response
        last_response
      end

      def body
        @body ||= begin
          ParsedBody.new(response.body)
        end
      end

    end
  end
end