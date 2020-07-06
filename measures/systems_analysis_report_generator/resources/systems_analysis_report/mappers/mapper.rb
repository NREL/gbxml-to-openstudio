module SystemsAnalysisReport
  module Mappers
    class Mapper
      def klass
        raise NotImplementedError, "Must be implemented by the subclass"
      end

      def mapping
        raise NotImplementedError, "Must be implemented by the subclass"
      end

      def call(from)
        result = klass.new

        mapping.each do |param|
          result.send("#{param[1]}=", from.send(param[0]))
        end

        result.validate

        return result
      end
    end
  end
end