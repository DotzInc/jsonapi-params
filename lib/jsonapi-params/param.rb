require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/string/inflections'

module JSONAPI
  module Param
    def self.included(target)
      target.send(:include, InstanceMethods)
      target.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :whitelist_attributes, :whitelist_relationships

      # Adds the parameters to whitelist of parameters
      #
      # @param name [Symbol] The name of parameter
      # @return [nil]
      def param(name)
        add_param(name)
      end

      # Adds a list of parameters to whitelist of parameters
      #
      # @param name [Array<Symbol>] Names of parameters
      # @return [nil]
      def params(*names)
        names.each { |name| add_param(name) }
      end

      # Adds a relationship one-to-one to whitelist of relationships
      #
      # @param name [Array<Symbol>] Names of relationships
      # @return [nil]
      def belongs_to(relationship_name)
        relationship_name = relationship_name.to_s

        @whitelist_relationships ||= []
        @whitelist_relationships << relationship_name.dasherize
        @whitelist_relationships << relationship_name.underscore unless @whitelist_relationships.include?(relationship_name.underscore)
      end

      private

      # Creates the whitelist of attributes
      #
      # @param [Symbol]
      # @return [nil]
      # @!scope class
      # @!visibility private
      def add_param(name)
        name = name.to_s

        @whitelist_attributes ||= []
        @whitelist_attributes << name.dasherize
        @whitelist_attributes << name.underscore unless @whitelist_attributes.include?(name.underscore)
      end
    end

    module InstanceMethods
      def initialize(params)
        raise InvalidParam, 'Data is required' if params.nil? || params['data'].nil?

        @data = params['data']
      end

      # @returns [Integer]
      # @!attribute [r]
      def id
        @data['id']
      end

      # @returns [String]
      # @!attribute [r]
      def type
        @data['type']
      end

      # Handles parameters to return sanitized attributes and their relationships
      #
      # @return [Hash]
      def attributes
        attributes = @data['attributes'] || {}
        attributes = attributes.slice(*self.class.whitelist_attributes)
        attributes = attributes.merge(relationships)
        collection_attributes = strong_parameters? ? attributes.to_unsafe_h : attributes.to_h

        collection_attributes.inject({}) do |attributes, (key, value)|
          attributes[key.to_s.underscore.to_sym] = value
          attributes
        end
      end

      # Handles parameters to return relationships
      #
      # @return [Hash]
      # @raise [RuntimeError] if the relationship is a one-to-many relationship.
      def relationships
        relationships = @data['relationships'] || {}
        relationships = relationships.slice(*self.class.whitelist_relationships)

        relationships.to_h.inject({}) do |relationships, (relationship_key, relationship_object)|
          data = relationship_object['data']

          if data.is_a?(Array)
            raise 'One-to-many relationship is not supported'
          elsif data.is_a?(Hash)
            params = params_klass(relationship_key).new(relationship_object)

            relationships["#{relationship_key}_id".to_sym] = params.id
          end

          relationships
        end
      end

      private

      # Get the key to create a constant of param class.
      #
      # @param [String]
      # @return [Object]
      # @!visibility private
      def params_klass(key)
        "#{key}Param".classify.constantize
      end

      # Are the attributes an ActionController::Parameters instance?
      #
      # @return [Boolean]
      # @!visibility private
      def strong_parameters?
        Object.const_defined?('ActionController::Parameters') && @data.is_a?(ActionController::Parameters)
      end
    end
  end
end
