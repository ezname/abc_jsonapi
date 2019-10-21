require 'active_support/concern'
require 'active_support/core_ext/string'
require 'active_support/json'
require 'i18n'
require 'byebug'
require 'abc_jsonapi/model'
require 'abc_jsonapi/collection'
require 'abc_jsonapi/included_resource'

module AbcJsonapi
  module Serializer
    extend ActiveSupport::Concern

    attr_reader :resource, :result_hash, :resource_type, :resource_attributes,
                :relationships, :virtual_attributes, :includes, :meta

    def initialize(resource, options = {})
      @resource = resource
      @result_hash = { data: nil }
      @resource_type = self.class.resource_type
      @resource_attributes = self.class.resource_attributes
      @relationships = self.class.relationships
      @virtual_attributes = self.class.virtual_attributes
      @includes = options[:include]
      @meta = options[:meta]
    end

    def serializable_hash
      return nil if resource.nil?

      result_hash[:meta] = meta if meta.present?
      result_hash[:data] = data_hash
      result_hash[:included] = included_hash if @includes.present?
      result_hash
    end

    def serialized_json
      ActiveSupport::JSON.encode(serializable_hash)
    end

    module ClassMethods
      class << self
        attr_reader :resource_attributes, :relationships, :virtual_attributes
      end

      @@resource_attributes = []
      @@relationships = []
      @@virtual_attributes = []

      def attributes(*attributes)
        @@resource_attributes = attributes
      end

      def has_one(relationship, &block)
        @@relationships << { type: :has_one, name: relationship, block: block }
      end

      def has_many(relationship, &block)
        @@relationships << { type: :has_many, name: relationship, block: block }
      end

      def belongs_to(relationship, &block)
        @@relationships << { type: :belongs_to, name: relationship, block: block }
      end

      def resource_type(rtype = nil)
        @@resource_type ||= rtype || Helpers.pluralize_if_necessary(default_type)
      end

      def attribute(name, &block)
        @@virtual_attributes << { name: name, block: block }
      end

      private

      def default_type
        self.to_s[/(\w+)Serializer$/, 1].tableize
      end
    end

    private

    def included_hash
      AbcJsonapi::IncludedResource.new(
        resource: resource,
        includes: includes,
        serializer_namespace: namespace
      ).serializable_hash
    end

    def namespace
      self.class.name.gsub(/()?\w+Serializer$/, '')
    end

    def data_hash
      if resource.is_a?(Enumerable)
        AbcJsonapi::Collection.new(
          collection: resource,
          resource_type: resource_type,
          resource_attributes: resource_attributes,
          virtual_attributes: virtual_attributes,
          relationships: relationships
        ).serializable_hash
      else
        AbcJsonapi::Model.new(
          model: resource,
          resource_type: resource_type,
          resource_attributes: resource_attributes,
          virtual_attributes: virtual_attributes,
          relationships: relationships
        ).serializable_hash
      end
    end
  end
end