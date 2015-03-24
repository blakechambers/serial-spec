module ActiveModel
  class Serializer

      def serializable_hash
        h = @object.as_json(@options)
        _stringify_bson_ids!(h)
      end

      private
      # stringify bson_ids
      def _stringify_bson_ids!(hash)
        hash.each do |key,value|
          if value.kind_of?(BSON::ObjectId)
            hash[key] = value.to_s
          end
        end
        hash 
      end
  end
end

