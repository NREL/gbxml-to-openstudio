module EPlusOut
  module Relations
    class Locations < Relation
      def initialize(gateway, mapper = Mappers::LocationMapper.new)
        super(gateway, mapper)
      end

      def name_field
        :row_name
      end

      def clauses
        {
            table_name: "Site:Location"
        }
      end

      def order_by
        [:column_name]
      end

      private
      def get_units(clauses, select: nil, order_by: nil)
        column_names = @gateway.where(clauses, select: :column_name, order_by: [name_field] + order_by)
        column_names.map do |column_name|
          result = column_name.match(/{(.*?)}/)
          result.nil? ? result : result[1]
        end
      end
    end
  end
end