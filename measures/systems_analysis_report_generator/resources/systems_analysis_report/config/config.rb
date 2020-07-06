module SystemsAnalysisReport
  class Config
    attr_reader :language, :units

    def initialize(opts={})
      if opts.key? :file_path
        file = File.open(opts[:file_path])
        data = JSON.load(file)
        @language = data['language']
        @units = Units.new(data['units'])
      end

      if opts.key? :units
        @units = opts[:units]
      end
    end
  end

  class Units
    attr_reader :data

    def initialize(data)
      define_methods(data)
    end

    def define_methods(data)
      data.each do |unit|
        Units.class_eval <<-EOS
          def #{unit['type'].downcase}
            '#{unit['forge_schema_unit'].split(':')[1].split('-')[0]}'
          end
        EOS
      end
    end
  end
end