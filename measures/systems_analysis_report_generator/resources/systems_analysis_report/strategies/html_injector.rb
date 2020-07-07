module SystemsAnalysisReport
  module Strategies
    class HtmlInjector
      CONFIG_TO_SUB = "{\"language\":\"en-US\",\"units\":{\"heat_transfer_rate\":\"W\",\"temperature\":\"C\",\"temperature_difference\":\"C\",\"humidity_ratio\":\"kg/kg\",\"flow_rate\":\"m3/s\",\"specific_heat\":\"J/kg/C\",\"density\":\"kg/m3\",\"percent\":\"percent\",\"outdoor_air_percentage\":\"percent\",\"heat_transfer_rate_per_area\":\"W/m2\",\"area_per_heat_transfer_rate\":\"m2/W\",\"flow_rate_per_area\":\"m3/s/m2\",\"flow_rate_per_heat_transfer_rate\":\"m3/s/W\",\"people\":\"unitless\",\"area\":\"m\"}}"

      def self.call(input_path, data, configuration, writer=SystemsAnalysisReport::Configuration::JSONWriter)
        bundle_js = input_path + "/bundle.js"
        file = File.read(bundle_js)
        text = file.sub("function(e){e.exports=JSON.parse('{\"design_psychrometrics\":{},\"system_load_summarys\":{},\"zone_load_summarys\":{}}')", "function(e){e.exports=JSON.parse('#{data}')")
        text = text.sub(CONFIG_TO_SUB, writer.(configuration))
        File.write('./report_bundle.js', text)

        index = input_path + "/index.html"
        file = File.read(index)
        File.write('./report.html', file)
      end
    end
  end
end