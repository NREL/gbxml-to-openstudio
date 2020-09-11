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

      def size
        return param_map.size
      end

      def call(data)
        result = klass.new

        if data
          param_map.each do |param|
            result.send("#{param[:name]}=", data[param[:index]])
          end
        end

        result
      end
    end
  end
end