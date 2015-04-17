require "json"
require "active_support/core_ext/hash/indifferent_access"

module SerialSpec

  class ParsedBody
    class MissingSelectorError < StandardError ; end

    attr_accessor :raw_body
    attr_accessor :selector
    attr_reader   :body

    def initialize(raw_body=nil, options={})
      @selector = options[:selector] || []
      @raw_body = raw_body
    end

    def body
      @body ||= JSON.parse(raw_body)
    end

    def [](*args)
      clone.tap do |b|
        b.selector.push([:[], *args])
      end
    end

    def first(*args)
      clone.tap do |b|
        b.selector.push([:first])
      end
    end

    def last(*args)
      clone.tap do |b|
        b.selector.push([:last])
      end
    end

    def execute
      copy = selector.clone
      selector.clear
      current_selector = []

      failure = catch(:failed) do

        return copy.inject(body) do |remainder, method_and_args|
          current_selector << method_and_args
          methud, *args = method_and_args

          if [:first, :last].include?(methud) || args.first.kind_of?(Fixnum)
            throw(:failed, [:expected_array, remainder, current_selector, method_and_args]) unless remainder.kind_of?(Array)
          else
            throw(:failed, [:expected_object, remainder, current_selector, method_and_args]) unless remainder.kind_of?(Hash)
          end

          if remainder.kind_of?(Hash)
            remainder.with_indifferent_access.send methud, *args
          else
            remainder.send methud, *args
          end

        end

      end

      if failure.kind_of?(Array)
        raise MissingSelectorError, failed_message(*failure)
      end
    end

  private ###############################

    def initialize_copy(other)
      @selector = other.selector.clone
      @raw_body = other.raw_body
    end

    def formatted_selector(selector)
      output = ""

      selector.each do |item|
        if item.first == :[]
          output << "[#{item.last.inspect}]"
        else
          output << "[#{item.first.inspect}]"
        end
      end
      output
    end

    def failed_message(msg, remainder, selector, current_selector)
      case msg
      when :expected_object
        "expected an object to have #{formatted_selector([current_selector])}, but found #{remainder.class}:\"#{remainder}\" at #{formatted_selector(selector[0..-2])}"
      when :expected_array
        "expected an array at \"#{formatted_selector(selector[0..-2])}\", but found #{remainder.class}:'#{remainder}'"
      end
    end

  end

end
