module EPlusOut
  module Gateways
    class SqlGateway
      attr_reader :sql_file

      def initialize(sql_file)
        @sql_file = sql_file
      end

      def where(params, select: :value, order_by: [], distinct: false)
        query = build_query(params, select: select, order_by: order_by, distinct: distinct)
        execute(query).map { |value| cast_type(value) }
      end

      # dangerous public entry :). Executes string as is
      def execute(query)
        @sql_file.execAndReturnVectorOfString(query).get
      end

      #private
      def build_query(params, select: :value, order_by: [], distinct: false)
        query = distinct ? "SELECT DISTINCT " : "SELECT "
        query += "#{camelize(select.to_s)} "
        query += "FROM TabularDataWithStrings"

        unless params.empty?
          query += " WHERE"
          query = params.reduce(query) { |query, param| query + " #{camelize(param[0].to_s)} = '#{param[1]}' AND" }[0..-5]
        end

        unless order_by.empty?
          query += " ORDER BY "
          query = order_by.reduce(query) { |query, order| query + "#{camelize(order.to_s)}, "}[0..-3] += " ASC"
        end

        query
      end

      def camelize(string)
        string.split('_').collect(&:capitalize).join
      end

      def cast_type(value)
        begin
          if value[-1] == "."
            value += "0"
          end
          Float(value)
        rescue
          value.empty? ? nil : value.strip
        end
      end
    end
  end
end

