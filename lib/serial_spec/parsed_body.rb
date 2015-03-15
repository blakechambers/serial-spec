require "json"

module SerialSpec

  class ParsedBody

    attr_reader :raw_body
    attr_reader :selector

    def initialize(body)
      @selector = []
      @raw_body = JSON.parse(body)
    end

    def self.add_selector(*methuds)
      methuds.each do |methud|
        class_eval <<-METHOD
          def #{methud.to_s}(*args)
            selector.push([#{methud.to_sym}, args])
          end
        METHOD
      end
    end

    add_selector :first, :last, :[]

    def execute
      selector.inject(raw_body) do |remainder, method_and_args|
        begin
          methud, args = method_and_args
          remainder.send method, args
        rescue => ex
          raise ArgumentError, "could not find '#{methud.inspect}' for: '#{remainder.inspect}'"
        end
      end
    end

  end

end