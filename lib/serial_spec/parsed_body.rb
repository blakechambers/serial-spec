require "json"
require "active_support/core_ext/hash/indifferent_access"

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
            self
          end
        METHOD
      end
    end

    add_selector :first, :last, :[]

    def [](*args)
      selector.push([:[], *args])
      self
    end

    def first(*args)
      selector.push([:first])
      self
    end

    def last(*args)
      selector.push([:last])
      self
    end

    def execute
      copy = selector.clone
      selector.clear
      copy.inject(raw_body) do |remainder, method_and_args|
        begin
          methud, *args = method_and_args
          if remainder.kind_of?(Hash)
            remainder.with_indifferent_access.send methud, *args
          else
            remainder.send methud, *args
          end
        rescue NoMethodError => ex
          raise ArgumentError, "could not find '#{methud.inspect}' \nfor:\n '#{remainder.inspect}' \nin\n #{raw_body}"
        end
      end
    end

  end

end
