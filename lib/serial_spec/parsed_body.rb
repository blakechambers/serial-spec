require "json"
require "active_support/core_ext/hash/indifferent_access"

module SerialSpec

  class ParsedBody
    class MissingSelectorError < StandardError ; end

    attr_reader :raw_body
    attr_reader :selector

    def initialize(body)
      @selector = []
      @raw_body = JSON.parse(body)
    end

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
      current_selector = []

      failure = catch(:failed) do

        return copy.inject(raw_body) do |remainder, method_and_args|
          # require 'byebug'
          # byebug
          current_selector << method_and_args
          methud, *args = method_and_args

          throw(:failed, [:expected_object, remainder, current_selector, method_and_args]) unless remainder.respond_to?(methud)

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

    def formatted_selector(selector)
      output = ""
      selector.each do |item|
        if item.first == :[]
          output << "[#{item.last}]"
        else
          output << item.first
        end
      end
      output
    end

    def failed_message(msg, remainder, selector, current_selector)
      case msg
      when :expected_object
        "expected an object to have #{formatted_selector([current_selector])}, but found #{remainder.class}:'#{remainder}' at #{formatted_selector(selector[0..-2])}"
      when :expected_array
        "expected an object to have #{formatted_selector([current_selector])}, but found #{remainder.class}:'#{remainder}' at #{formatted_selector(selector[0..-2])}"
      end
    end

  end

end
