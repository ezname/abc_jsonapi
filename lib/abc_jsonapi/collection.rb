require 'abc_jsonapi/model'

module AbcJsonapi
  class Collection
    attr_reader :collection, :resource_type, :resource_attributes, :virtual_attributes, :relationships

    def initialize(collection:, resource_type:, resource_attributes:, virtual_attributes:, relationships:)
      @collection = collection
      @resource_type = resource_type
      @resource_attributes = resource_attributes
      @virtual_attributes = virtual_attributes
      @relationships = relationships
    end

    def serializable_hash
      collection.map do |model|
        AbcJsonapi::Model.new(
          model: model,
          resource_type: resource_type,
          resource_attributes: resource_attributes,
          virtual_attributes: virtual_attributes,
          relationships: relationships
        ).serializable_hash
      end
    end
  end
end