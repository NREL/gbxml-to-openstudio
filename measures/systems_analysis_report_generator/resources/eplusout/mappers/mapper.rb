module EPlusOut
  module Mappers
    class Mapper
      attr_reader :sql_file

      def param_map
        raise NotImplementedError, 'Must be implemented by child class'
      end

      def klass
        raise NotImplementedError, 'Must be implemented by child class'
      end

      def call(data)
        result = klass.new

        param_map.each do |param|
          result.send("#{param[:name]}=", cast_type(data[param[:index]], param[:type]))
        end

        return result
      end

      private
      def cast_type(value, type)
        return nil if (value == nil || value.empty?)

        return value.to_f if type=="double"

        value
      end
    end
  end
end