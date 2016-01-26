require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/string/inflections'

module JSONAPI
  module Params
    def self.included(target)
      target.send(:include, InstanceMethods)
      target.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :whitelist_attributes

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

        relationships.inject({}) do |relationships, (relationship_key, relationship_object)|
          data = relationship_object['data']

          if data.is_a?(Array)
            raise 'Many-to-many relationship is not supported'
          elsif data.is_a?(Hash)
            relationships["#{relationship_key}_id"] = data['id']
          end

          relationships
        end
      end
    end
  end
end
