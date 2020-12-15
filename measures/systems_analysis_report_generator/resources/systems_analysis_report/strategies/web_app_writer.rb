module SystemsAnalysisReport
  module Strategies
    class WebAppWriter
      def self.call(input_path, data, configuration)

        # inject data and config into the bundle.js file
        bundle_js = File.read(input_path + "/bundle.js")
        text = bundle_js.sub("JSON.parse('{\"design_psychrometrics\":{},\"system_load_summarys\":{},\"zone_load_summarys\":{}}')", "JSON.parse('#{data}')")
        text = text.sub(/{"language.*?}}/, configuration.to_json)
        File.write('./report_bundle.js', text)

        index = input_path + "/index.html"
        file = File.read(index)
        File.write('./report.html', file)
      end
    end
  end
end