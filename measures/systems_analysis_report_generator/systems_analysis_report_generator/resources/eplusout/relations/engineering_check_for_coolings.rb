module EPlusOut
  module Relations
    class EngineeringCheckForCoolings < Relation
      def initialize(gateway, mapper = Mappers::EngineeringCheckMapper.new)
        super(gateway, mapper)
      end

      def name_field
        :report_for_string
      end

      def clauses
        {
            table_name: "Engineering Checks for Cooling"
        }
      end

      def order_by
        [:row_name]
      end
    end
  end
end