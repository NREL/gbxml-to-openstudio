module SystemsAnalysisReport
  module Mappers
    class EstimatedPeakLoadComponentTableToPeakLoadComponentTable
      attr_reader :peak_load_component_mapper

      def initialize(peak_load_component_mapper = PeakLoadComponentMapper.new)
        @peak_load_component_mapper = peak_load_component_mapper
      end

      def call(estimated_peak_load_component_table)
        result = Models::SystemPeakLoadComponentTable.new

        load_members = estimated_peak_load_component_table.excluded_members([:name, :grand_total])
        load_members.map { |member| result[member] = @peak_load_component_mapper.(estimated_peak_load_component_table[member]) unless estimated_peak_load_component_table[member].nil? }
        result
      end
    end
  end
end