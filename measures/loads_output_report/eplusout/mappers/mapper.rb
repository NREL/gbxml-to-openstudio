﻿module EPlusOut
  module Mappers
    class Mapper
      def param_map
        raise NotImplementedError, 'Must be implemented by child class'
      end

      def klass
        raise NotImplementedError, 'Must be implemented by child class'
      end

      def call(data)
        result = klass.new

        param_map.each do |param|
          result.send("#{param[:name]}=", self.class.cast_type(data[param[:index]], param[:type]))
        end

        return result
      end

      def self.cast_type(value, type)
        if type == "double"
          value = value.to_f
        end

        value
      end
    end
  end
end