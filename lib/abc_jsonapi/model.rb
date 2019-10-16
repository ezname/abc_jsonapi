require 'abc_jsonapi/virtual_attribute'
require 'abc_jsonapi/relationship'

module AbcJsonapi
  class Model
    attr_reader :model, :resource_type, :resource_attributes, :virtual_attributes, :relationships

    def initialize(model:, resource_type:, resource_attributes:, virtual_attributes:, relationships:)
      @model = model
      @resource_type = resource_type.to_sym
      @resource_attributes = resource_attributes
      @virtual_attributes = virtual_attributes
      @relationships = relationships
    end

    def serializable_hash
      data = {}
      data[:id] = model.id.to_s
      data[:type] = resource_type
      data[:attributes] = transform_keys_if_necessary(attributes_hash)
      data[:relationships] = transform_keys_if_necessary(relationships_hash, true) if relationships.any?
      data
    end

    private

    def attributes_hash
      result = {}
      resource_attributes.each do |attribute|
        result.merge!(attribute => model.public_send(attribute))
      end

      virtual_attributes.each do |attribute|
        attribute = AbcJsonapi::VirtualAttribute.new(
          model: model,
          name: attribute[:name],
          block: attribute[:block]
        )
        result.merge!(attribute.serializable_hash)
      end

      result
    end

    def relationships_hash
      result = {}
      relationships.each do |relationship|
        rel_model = AbcJsonapi::Relationship.new(
          model: model,
          relationship: relationship[:name],
          type: relationship[:type]
        )
        result[relationship[:name].to_sym] = rel_model.serializable_hash
      end
      result
    end

    def transform_keys_if_necessary(hash, deep = false)
      transform_method = deep ? 'deep_transform_keys' : 'transform_keys'

      if AbcJsonapi.config.transform_keys
        case AbcJsonapi.config.key_transform_method
        when 'camel'
          hash.public_send(transform_method){ |key| key.to_s.camelize(:lower).to_sym }
        when 'snake'
          hash.public_send(transform_method){ |key| key.to_s.underscore.to_sym }
        end
      end
    end

  end
end