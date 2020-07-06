module SystemsAnalysisReport
  module Models
    Report = Struct.new(:zone_load_summarys, :system_load_summarys, :design_psychrometrics) do
      # include Models::Model

      def to_json(*args)
        zone_load_summarys = Hash[self.zone_load_summarys.collect { |v| [v.name, v] }]
        system_load_summarys = Hash[self.system_load_summarys.collect { |v| [v.name, v] }]
        design_psychrometrics = Hash[self.design_psychrometrics.collect { |v| [v.name, v] }]

        return {:zone_load_summarys => zone_load_summarys, :system_load_summarys => system_load_summarys, :design_psychrometrics => design_psychrometrics}.to_json
      end
    end
  end
end