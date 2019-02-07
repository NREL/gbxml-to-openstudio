module Mappers
  class BaseMapper
    attr_accessor :loaded_objects, :os_model

    def initialize(os_model)
      @os_model = os_model
      @loaded_objects = {}
    end
  end
end