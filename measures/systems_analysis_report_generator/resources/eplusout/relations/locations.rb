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
    end
  end
end