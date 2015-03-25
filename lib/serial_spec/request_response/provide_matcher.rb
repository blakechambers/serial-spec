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
        attr_reader :actual

        HYPERMEDIA_ATTRIBUTES = ["links", "includes"]

        def initialize(expected,options={})
          @expected       = expected
          @as_serializer  = options[:as]
          @with_root      = options[:with_root]
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
            as_serializer.new(expected, root: with_root)
          else
            unless expected.respond_to?(:active_model_serializer)
              throw(:failed, :serializer_not_specified_on_class)
            end
            expected.active_model_serializer.new(expected,root: with_root)
          end
        end

        def collection_serializer
          if as_serializer
            ActiveModel::ArraySerializer.new(expected,serializer: as_serializer, root: with_root )
          else
            ActiveModel::ArraySerializer.new(expected, root: with_root)
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
            data.each_with_index do |el,index|
              data[index] = normalize_data(el)
            end
          elsif data.kind_of?(Hash)
            data.deep_stringify_keys!.to_hash
          end
        end

       def strip_hypermedia(actual)
         actual.delete_if {|k,v| HYPERMEDIA_ATTRIBUTES.include?(k) }
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
