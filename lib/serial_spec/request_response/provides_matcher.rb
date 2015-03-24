require 'active_support/inflector'
require 'yaml'


module SerialSpec
  module RequestResponse
    module ProvideMatcher

      def provide(expected,options={})
        SerialSpec::RequestResponse::ProvideMatcher::Provide.new(expected, options)
      end

      class Provide
        class SerializerNotFound < StandardError ; end

        attr_reader :as_serializer
        attr_reader :with_root
        attr_reader :expected

        def initialize(expected,options={})
          @expected       = expected
          @as_serializer  = options[:as]
          @with_root      = options[:with_root]
        end

        def actual_to_hash(actual)
          if actual.kind_of? SerialSpec::ParsedBody 
            actual.execute
          else
            actual
          end
        end

        def resource_hash
          if as_serializer
            as_serializer.new(expected, root: with_root).as_json
          else
            unless expected.respond_to?(:active_model_serializer)
              throw(:failed, :serializer_not_specified_on_class)
            end
            expected.active_model_serializer.new(expected,root: with_root).as_json
          end
        end

        def collection_hash
          if as_serializer
            ActiveModel::ArraySerializer.new(expected,serializer: as_serializer, root: with_root ).as_json
          else
            ActiveModel::ArraySerializer.new(expected, root: with_root).as_json
          end
        end

        def expected_to_hash
          if expected.kind_of?(Array)
            collection_hash
          else
            resource_hash
          end
        end

        # TODO: improve this to be unordered comparison of keys/values for deep hashes
        # for now a lazy deep comparison, look ma' no iteration!

        def deep_match?(actual,expected_hash)
          unless actual.kind_of?(Hash)
            throw(:failed, :response_not_valid)
          end
          actual_cleaned = normalize_data(actual)
          expected_cleaned = normalize_data(expected_hash)
          if actual_cleaned.to_yaml.eql?(expected_cleaned.to_yaml)
          else
            throw(:failed, :response_and_model_dont_match)
          end
        end

       def normalize_data(data)
          if data.kind_of?(Array)
            data.each_with_index do |el,index|
              data[index] = normalize_data(el)
            end
          elsif data.kind_of?(Hash)
            data.deep_stringify_keys!.to_hash
          end
        end

        def matches?(actual)
          failure = catch(:failed) do
            deep_match?(actual_to_hash(actual),expected_to_hash) 
          end
          @failure_message = failed_message(failure) if failure 
          !failure
        end

        # when rspec asserts eq
        alias == matches?

        def failed_message(msg) 
          case msg
          when :response_and_model_dont_match
            "response and serialized object do not match" 
          when :serializer_not_valid
            "serializer not valid"
          when :serializer_not_specified_on_class
            "serializer not specified on class, see http://bit.ly/18TdmXs"
          when :response_not_valid
            "response not valid or hash"
          else
            "no failed_message found, this is default"
          end
        end

        def failure_message
          @failure_message || "error should TO  implement"
        end

        def failure_message_when_negated
          @failure_message || "error should not  TO implement"
        end

      end

    end
  end
end
