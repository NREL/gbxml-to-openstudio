﻿module EPlusOut
  module Repositories
    class EngineeringChecksRepository
      attr_accessor :sql_file, :mapper

      BASE_QUERY = "SELECT Value FROM TabularDataWithStrings"

      def initialize(sql_file, mapper)
        @sql_file = sql_file
        @mapper = mapper
      end

      def build_query(name, conditioning)
        BASE_QUERY + " WHERE TableName = 'Engineering Checks for #{conditioning}' AND UPPER(ReportForString) = '#{name.upcase}'  ORDER BY RowName ASC"
      end

      def find_by_name_and_conditioning(name, conditioning)
        component_query = build_query(name, conditioning)
        result = @sql_file.execAndReturnVectorOfString(component_query)

        return nil if result.nil?

        return mapper.(result)
      end
    end
  end
end