module EPlusOut
  module Relations
    class Relation
      attr_reader :gateway, :mapper, :instances

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
        load if @instances.nil?

        @instances[name.upcase]
      end

      def all
        @instances
      end

      private
      def load
        @instances = {}

        names = @gateway.where(clauses, select: name_field, order_by: [name_field] + order_by, distinct: true)
        data = @gateway.where(clauses, select: :value, order_by: [name_field] + order_by)

        names.each_with_index do |name, idx|
          instance_data = data.slice(idx * @mapper.size, @mapper.size)
          result = @mapper.(instance_data)
          result.name = name
          @instances[name] = result
        end
      end
    end
  end
end