module AbcJsonapi
  class IncludedResource
    attr_reader :resource, :includes, :serializer_namespace, :includes_result

    def initialize(resource:, includes:, serializer_namespace:)
      @includes_result = []
      @resource = resource
      @includes = includes
      @serializer_namespace = serializer_namespace
    end

    def serializable_hash
      includes.each do |include_path|
        include_chain = include_path.split('.')
        get_included_records(resource, include_chain.dup)
      end
      includes_result.flatten
    end

    def get_included_records(resource, include_chain)
      return if resource.nil? || include_chain.empty?

      # Get first include name of include_chain and delete it from include_chain
      inc_resource_name = include_chain.shift

      # Check if include name is exist in relationships array. Take it or return nil
      resource_class_name = resource.is_a?(Enumerable) ? resource[0].class.name : resource.class.name
      relationship = serializer(resource_class_name).relationships.find { |h| h[:name] == inc_resource_name.to_sym }
      return if relationship.nil?

      # Get included resource
      if resource.is_a?(Enumerable)
        resource = collection.map{ |res| res.public_send(inc_resource_name) }.flatten.reject(&:nil?).uniq{ |item| item.id }
      else
        resource = resource.public_send(inc_resource_name)
      end
      return if resource.nil?
      
      @includes_result << serializer(inc_resource_name).new(resource).serializable_hash[:data]
      
      # If resource is a collection call get_included_records for each. Otherwise send whole resource
      if resource.is_a?(Enumerable)
        resource.each do |single_res|
          get_included_records(single_res, include_chain.dup)
        end
      else
        get_included_records(resource, include_chain)
      end
    end

    def serializer(included_resource_name)
      (serializer_namespace + included_resource_name.to_s.classify + 'Serializer').constantize
    end

  end
end