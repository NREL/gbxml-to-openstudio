module SystemsAnalysisReport
  module Strategies
    class ZoneNameGetter
      def self.call(model)
        model.getThermalZones.map { |zone| zone.name.get  }
      end
    end
  end
end