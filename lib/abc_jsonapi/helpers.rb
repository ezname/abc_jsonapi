module Helpers
  def self.pluralize_if_necessary(resource_type)
    return resource_type if !AbcJsonapi.config.pluralize_resources
    resource_type.pluralize
  end
end