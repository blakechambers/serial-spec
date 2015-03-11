require "inheritable_accessors/inheritable_hash_accessor"

module SerialSpec
  module ItExpects
    extend ActiveSupport::Concern
    include InheritableAccessors::InheritableHashAccessor

    included do
      include ::SerialSpec::ItExpects::DSL
      extend  ::SerialSpec::ItExpects::DSL

      inheritable_hash_accessor :__inherited_expectations__

      after(:each) do
        __inherited_expectations__.to_hash.each do |name, block|
          instance_exec(&block)
        end
      end

    end

    module DSL

      def it_expects(name, &block)
        __inherited_expectations__[name] = block
      end

    end

  end
end