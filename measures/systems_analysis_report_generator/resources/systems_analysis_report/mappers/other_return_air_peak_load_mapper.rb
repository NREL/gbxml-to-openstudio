module SystemsAnalysisReport
  module Mappers
    class OtherReturnAirPeakLoadMapper
      def klass
        Models::PeakLoadComponent
      end

      def call(estimated_peak_load_component_table)
        load_members = estimated_peak_load_component_table.excluded_members([:name, :lights, :grand_total])
        sensible_return_air = load_members.inject(0) { |sum, member|
          estimated_peak_load_component_table[member] ? sum + estimated_peak_load_component_table[member].sensible_return_air.to_f : sum
        }
        result = Models::PeakLoadComponent.new
        result.sensible_instant = sensible_return_air
        result.validate
        result
      end
    end
  end
end