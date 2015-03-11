require "active_support/concern"
require "serial_spec/version"
require "serial_spec/it_expects"
require "serial_spec/request_response"
require "inheritable_accessors"

module SerialSpec
  extend ActiveSupport::Concern

  include ItExpects
  include RequestResponse
end
