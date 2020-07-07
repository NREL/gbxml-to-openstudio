module EPlusOut
  module Relations
    class EstimatedHeatingPeakLoadComponentTables < Relation
      def initialize(gateway, mapper = Mappers::EstimatedPeakLoadComponentTableMapper.new)
        super(gateway, mapper)
      end

      def name_field
        :report_for_string
      end

      def clauses
        {
            table_name: "Estimated Heating Peak Load Components"
        }
      end

      def order_by
        [:row_name, :column_name]
      end
    end
  end
end