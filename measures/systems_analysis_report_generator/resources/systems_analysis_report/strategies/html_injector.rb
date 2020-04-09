module SystemsAnalysisReport
  module Strategies
    class HtmlInjector
      def self.call(input_path, data)
        bundle_js = input_path + "/bundle.js"
        file = File.read(bundle_js)
        text = file.sub("function(e){e.exports=JSON.parse()", "function(e){e.exports=JSON.parse('#{data}')")
        File.write('./report_bundle.js', text)

        index = input_path + "/index.html"
        file = File.read(index)
        File.write('./report.html', file)
      end
    end
  end
end