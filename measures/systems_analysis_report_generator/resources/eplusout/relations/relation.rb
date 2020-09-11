module EPlusOut
  module Relations
    class Relation
      attr_reader :gateway, :mapper, :instances, :unit_system

      def initialize(gateway, mapper, unit_system=EPlusOut::Utilities::SIUnitSystem.new)
        @gateway = gateway
        @mapper = mapper
        @unit_system = unit_system
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
        load if @instances.nil?
        @instances
      end

      def first
        load if @instances.nil?
        @instances.values()[0]
      end

      private
      def load
        @instances = {}

        names = @gateway.where(clauses, select: name_field, order_by: [name_field] + order_by, distinct: true)
        data = @gateway.where(clauses, select: :value, order_by: [name_field] + order_by)
        units = get_units(clauses, select: :units, order_by: [name_field] + order_by)

        names.each_with_index do |name, idx|
          instance_data = data.slice(idx * @mapper.size, @mapper.size)
          instance_units = units.slice(idx * @mapper.size, @mapper.size)
          converted_data = instance_data.zip(instance_units).map { |data, unit| @unit_system.to_unit_system(data, unit) }

          result = @mapper.(converted_data)
          result.name = name
          @instances[name] = result
        end
      end

      def get_units(clauses, select: :units, order_by: nil)
        @gateway.where(clauses, select: :units, order_by: [name_field] + order_by)
      end
    end
  end
end