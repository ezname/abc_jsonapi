require "abc_jsonapi/version"
require "abc_jsonapi/serializer"
require "abc_jsonapi/helpers"

module AbcJsonapi
  class << self
    attr_reader :config

    def configure
      yield(config)
    end
  end

  class Configuration
    attr_accessor :transform_keys, :key_transform_method, :pluralize_resources

    def initialize
      @transform_keys ||= true
      @key_transform_method ||= 'camel' # snake or camel
      @pluralize_resources ||= false
    end
  end
  
  @config ||= Configuration.new
  
  class Error < StandardError; end
end
