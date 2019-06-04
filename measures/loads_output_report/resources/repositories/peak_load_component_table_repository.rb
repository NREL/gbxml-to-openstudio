require_relative '../peak_load_component_table'
require_relative '../peak_load_component'
# require_relative 'repositories/peak_load_component_repository'

class PeakLoadComponentTableRepository
  attr_accessor :sql_file, :names

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings"
  COLUMN_PARAM_MAP = [
      {:db_index => 0, :param_name => :percent_grand_total, :param_type => 'double'},
      {:db_index => 1, :param_name => :latent, :param_type => 'double'},
      {:db_index => 2, :param_name => :related_area, :param_type => 'double'},
      {:db_index => 3, :param_name => :sensible_delayed, :param_type => 'double'},
      {:db_index => 4, :param_name => :sensible_instant, :param_type => 'double'},
      {:db_index => 5, :param_name => :sensible_return_air, :param_type => 'double'},
      {:db_index => 6, :param_name => :total, :param_type => 'double'},
      {:db_index => 7, :param_name => :total_per_area, :param_type => 'double'},
  ]

  ROW_PARAM_MAP = [
      {:db_index => 0, :param_name => :doas_direct_to_zone},
      {:db_index => 1, :param_name => :equipment},
      {:db_index => 2, :param_name => :exterior_floor},
      {:db_index => 3, :param_name => :exterior_wall},
      {:db_index => 4, :param_name => :fenestration_conduction},
      {:db_index => 5, :param_name => :fenestration_solar},
      {:db_index => 6, :param_name => :grand_total},
      {:db_index => 7, :param_name => :ground_contact_floor},
      {:db_index => 8, :param_name => :ground_contact_wall},
      {:db_index => 9, :param_name => :hvac_equipment_loss},
      {:db_index => 10, :param_name => :infiltration},
      {:db_index => 11, :param_name => :interzone_ceiling},
      {:db_index => 12, :param_name => :interzone_floor},
      {:db_index => 13, :param_name => :interzone_mixing},
      {:db_index => 14, :param_name => :interzone_wall},
      {:db_index => 15, :param_name => :lights},
      {:db_index => 16, :param_name => :opaque_door},
      {:db_index => 17, :param_name => :other_floor},
      {:db_index => 18, :param_name => :other_roof},
      {:db_index => 19, :param_name => :other_wall},
      {:db_index => 20, :param_name => :people},
      {:db_index => 21, :param_name => :power_generation_equipment},
      {:db_index => 22, :param_name => :refrigeration},
      {:db_index => 23, :param_name => :roof},
      {:db_index => 24, :param_name => :water_use_equipment},
      {:db_index => 25, :param_name => :zone_ventilation},
  ]

  def initialize(sql_file)
    @sql_file = sql_file

    names_query = "SELECT DISTINCT UPPER(ReportForString) From TabularDataWithStrings WHERE TableName == 'Estimated Cooling Peak Load Components'"
    @names = @sql_file.execAndReturnVectorOfString(names_query).get
  end

  # @param name [String] the name of the object
  # @param conditioning [String] "heating" or "cooling"
  def find_by_name_and_conditioning(name, conditioning)

    return unless names.include? name.upcase

    query = "SELECT Value FROM TabularDataWithStrings WHERE TableName = 'Estimated #{conditioning} Peak Load Components'
AND UPPER(ReportForString) = '#{name}' ORDER BY RowName, ColumnName ASC"

    result = @sql_file.execAndReturnVectorOfString(query)

    return nil if result.nil?

    result = result.get

    params = {}

    ROW_PARAM_MAP.each do |row_param|
      peak_load_params = {}

      COLUMN_PARAM_MAP.each do |column_param|
        peak_load_params[column_param[:param_name]] = cast_type(result[row_param[:db_index] * COLUMN_PARAM_MAP.size + column_param[:db_index]], column_param[:param_type])
      end

      params[row_param[:param_name]] = PeakLoadComponent.new(peak_load_params)
    end

    PeakLoadComponentTable.new(params)
  end

  private

  def cast_type(value, type)
    if type == "double"
      value = value.to_f
    end

    value
  end
end