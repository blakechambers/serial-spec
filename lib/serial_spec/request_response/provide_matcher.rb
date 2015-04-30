require 'active_support/inflector'
require 'yaml'

module SerialSpec
  module RequestResponse
    module ProvideMatcher

      def provide(expected,options={})
        SerialSpec::RequestResponse::ProvideMatcher::Provide.new(self, expected, options)
      end

      def build_serializer(serializer, object, options)
        serializer.new object, options
      end

      class Provide
        class SerializerNotFound < StandardError ; end

        extend Forwardable

        attr_reader :as_serializer
        attr_reader :expected
        attr_reader :actual

        def_delegator :@build_context, :build_serializer

        HYPERMEDIA_ATTRIBUTES = ["links", "includes"]

        def initialize(build_context, expected, options={})
          @build_context  = build_context
          @expected       = expected
          @as_serializer  = options[:as]

          if @as_serializer and not @as_serializer.instance_methods.include?(:serializable_hash)
            raise ArgumentError, 'must be an active model serializer'
          end
        end

        def actual_to_hash(actual)
          if actual.kind_of? SerialSpec::ParsedBody
            strip_hypermedia(actual.execute)
          else
            strip_hypermedia(actual)
          end
        end

        def resource_serializer
          if as_serializer
            build_serializer as_serializer, expected, root: nil
          else
            unless expected.respond_to?(:active_model_serializer)
              throw(:failed, :serializer_not_specified_on_class)
            end
            build_serializer expected.active_model_serializer, expected, root: nil
          end
        end

        def collection_serializer
          if as_serializer
            build_serializer ActiveModel::ArraySerializer, expected, serializer: as_serializer, root: nil
          else
            build_serializer ActiveModel::ArraySerializer, expected, root: nil
          end
        end

        # to_json first to normalize hash and all it's members
        # the parse into JSON to compare to ParsedBody hash
        def expected_to_hash
          if expected.kind_of?(Array)
            #hack
            JSON.parse(collection_serializer.as_json.to_json)
          else
            JSON.parse(resource_serializer.to_json)
          end
        end

       def normalize_data(data)
          if data.kind_of?(Array)
            data.each_with_index do |el, index|
              data[index] = normalize_data(el)
            end
          elsif data.kind_of?(Hash)
            data.deep_stringify_keys!.to_hash
          end
        end

       def strip_hypermedia(actual)
         (actual || {}).delete_if {|k,v| HYPERMEDIA_ATTRIBUTES.include?(k) }
       end

       def matches?(actual)
         failure = catch(:failed) do

           unless actual.kind_of?(Hash) || actual.kind_of?(Array) || actual.kind_of?(ParsedBody)
             throw(:failed, :response_not_valid)
           end

           @actual    = actual_to_hash(actual)
           @expected  = expected_to_hash

           if @actual == @expected
             #noop - specs pass
           else
             throw(:failed, :response_and_model_dont_match)
           end
         end
         @failure_message = failed_message(failure) if failure
         !failure
       end

        # when rspec asserts eq
        alias == matches?

        def failed_message(msg)
          case msg
          when :response_and_model_dont_match
            "Actual and Expected do not match.\nActual   #{actual}\nExpected #{expected}"
          when :serializer_not_specified_on_class
            "'active_model_serializer' not implemented on expected, see ehttp://bit.ly/18TdmXs"
          when :response_not_valid
            "Actual not valid Hash or Array.\nActual: #{actual}"
          else
            "no failed_message found for #{msg}"
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
