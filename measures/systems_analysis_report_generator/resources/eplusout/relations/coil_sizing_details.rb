module EPlusOut
  module Relations
    class CoilSizingDetails < Relation
      def initialize(gateway, mapper = Mappers::CoilSizingDetailMapper.new)
        super(gateway, mapper)
      end

      def name_field
        :row_name
      end

      def clauses
        {
            table_name: "Coils"
        }
      end

      def order_by
        [:column_name]
      end
    end
  end
end

#"SELECT Value FROM TabularDataWithStrings WHERE TableName = 'Coils' AND UPPER(RowName) == '#{name.upcase}' ORDER BY ColumnName ASC"
