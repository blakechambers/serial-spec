require "rack/test"
require "inheritable_accessors/inheritable_hash_accessor"

module SerialSpec
  module RequestResponse
    extend ActiveSupport::Concern
    include Rack::Test::Methods
    include InheritableAccessors::InheritableHashAccessor

    included do
      include ::SerialSpec::RequestResponse::DSL
      extend  ::SerialSpec::RequestResponse::DSL

      inheritable_hash_accessor :request_opts
      inheritable_hash_accessor :request_params
      inheritable_hash_accessor :request_envs
    end

    def perform_request!
      env = request_envs.merge(:method => request_method, :params => request_params.to_hash)
      env = current_session.send :env_for, request_path, env

      current_session.send :process_request, request_path, env
    end

    module DSL

      def request_path(new_path=nil)
        if new_path
          request_opts[:path] = new_path
        else
          path = request_opts[:path]
          return path if path
          raise "You must configure a path"
        end
      end

      # GET, POST, PUT, DELETE, OPTIONS, HEAD
      def request_method(new_method=nil)
        if new_method
          request_opts[:method] = new_method
        else
          methud = request_opts[:method]
          return methud if methud
          raise "You must configure a request method"
        end
      end


    end

  end
end