module EPlusOut
  module Relations
    class CoolingPeakConditions < Relation
      def initialize(gateway, mapper = Mappers::PeakConditionMapper.new)
        super(gateway, mapper)
      end

      def name_field
        :report_for_string
      end

      def clauses
        {
            table_name: "Cooling Peak Conditions"
        }
      end

      def order_by
        [:row_name]
      end
    end
  end
end