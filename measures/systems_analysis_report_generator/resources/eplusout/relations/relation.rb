module EPlusOut
  module Relations
    class Relation
      attr_reader :gateway, :mapper

      def initialize(gateway, mapper)
        @gateway = gateway
        @mapper = mapper
      end

      def name_field
        raise NotImplementedError, 'Must be implemented by child class'
      end

      def clauses
        {}
      end

      def order_by
        []
      end

      def clauses_with_name(name)
        clauses.merge(name_field => name.upcase)
      end

      def find_by_name(name)
        result = nil

        data = @gateway.where(clauses_with_name(name), order_by:order_by, distinct: false)

        unless data.empty?
          result = @mapper.(data)
          result.name = name
        end

        return result
      end

      def all
        names = gateway.where(clauses, select: name_field, order_by: order_by, distinct: true)

        return names.reduce([]) {|results, name| results << find_by_name(name)}
      end
    end
  end
end