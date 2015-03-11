require "json"

module SerialSpec

  module ParsedBody
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
        JSON.parse(response.body)
      end
    end

  end

end