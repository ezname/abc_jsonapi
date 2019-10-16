module AbcJsonapi
  class VirtualAttribute
    attr_reader :model, :name, :block

    def initialize(model:, name:, block:)
      @model = model
      @name = name
      @block = block
    end

    def serializable_hash
      { name.to_sym => block.call(model) }
    end
  end
end