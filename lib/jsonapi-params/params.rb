require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/string/inflections'

module JSONAPI
  module Params
    def self.included(target)
      target.send(:include, InstanceMethods)
      target.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :whitelist_attributes, :whitelist_relationships

      def param(name)
        add_param(name)
      end

      def params(*names)
        names.each { |name| add_param(name) }
      end

      def add_param(name)
        @whitelist_attributes ||= []
        @whitelist_attributes << name.to_s.dasherize
      end

      def belongs_to(relationship_names)
        @whitelist_relationships ||= []
        @whitelist_relationships << relationship_names.to_s.dasherize
      end
    end

    module InstanceMethods
      def initialize(params)
        raise InvalidParams, 'Data is required' if params.nil? || params['data'].nil?

        @data = params['data']
      end

      def id
        @data['id']
      end

      def type
        @data['type']
      end

      def attributes
        attributes = @data['attributes'] || {}
        attributes = attributes.slice(*self.class.whitelist_attributes)
        attributes = attributes.merge(relationships)
        attributes
      end

      def relationships
        relationships = @data['relationships'] || {}
        relationships = relationships.slice(*self.class.whitelist_relationships)

        relationships.inject({}) do |relationships, (relationship_key, relationship_object)|
          data = relationship_object['data']

          if data.is_a?(Array)
            raise 'Many-to-many relationship is not supported'
          elsif data.is_a?(Hash)
            params = params_klass(relationship_key).new(relationship_object)

            relationships["#{relationship_key}_id"] = params.id
          end

          relationships
        end
      end

      private

      def params_klass(key)
        "#{key}Param".classify.constantize
      end
    end
  end
end
