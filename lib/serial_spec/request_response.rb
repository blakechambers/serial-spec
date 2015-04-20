require "rack/test"
require "inheritable_accessors/inheritable_hash_accessor"
require "inheritable_accessors/inheritable_option_accessor"
require "serial_spec/request_response/helpers"

module SerialSpec
  module RequestResponse
    extend ActiveSupport::Concern
    include Rack::Test::Methods
    include InheritableAccessors::InheritableHashAccessor
    include InheritableAccessors::InheritableOptionAccessor
    include Helpers

    included do
      inheritable_hash_accessor :request_opts
      inheritable_hash_accessor :request_params
      inheritable_hash_accessor :request_envs

      inheritable_option_accessor :request_path, :request_method, for: :request_opts
    end

    def perform_request!
      env = request_envs.merge(:method => request_method, :params => request_params.to_hash)
      env = current_session.send :env_for, request_path, env

      current_session.send :process_request, request_path, env
    end

  end
end
