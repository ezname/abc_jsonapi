module AbcJsonapi
  class Relationship
    attr_reader :model, :relationship, :type

    def initialize(model:, relationship:, type:)
      @model = model
      @relationship = relationship
      @type = type
    end

    def serializable_hash
      case type
      when :has_one
        { data: serialize_has_one }
      when :has_many
        { data: serialize_has_many }
      when :belongs_to
        { data: serialize_belongs_to }
      else
        { data: nil }
      end
    end

    def serialize_has_one
      data = {}
      rel = model.public_send(relationship)
      return if rel.nil?
      data[:id] = rel.id.to_s
      data[:type] = Helpers.pluralize_if_necessary(relationship.to_s).to_sym
      data
    end

    def serialize_has_many
      data = model.public_send(relationship).map do |relation|
        {
          id: relation.id.to_s,
          type: Helpers.pluralize_if_necessary(relationship.to_s).to_sym
        }
      end
      data
    end

    def serialize_belongs_to
      data = {}
      id = model.public_send("#{relationship}_id")
      return if id.blank?
      data[:id] = id.to_s
      data[:type] = Helpers.pluralize_if_necessary(relationship.to_s).to_sym
      data
    end
  end
end