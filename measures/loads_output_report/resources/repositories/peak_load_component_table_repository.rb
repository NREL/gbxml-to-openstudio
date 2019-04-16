require_relative '../peak_load_component_table'
require_relative '../peak_load_component'
# require_relative 'repositories/peak_load_component_repository'

class PeakLoadComponentTableRepository
  attr_accessor :sql_file, :peak_load_component_repository

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings"
  ROW_PARAM_MAP = [
      {:component => 'People', :param_name => 'people'},
      {:component => 'Lights', :param_name => 'lights'},
      {:component => 'Equipment', :param_name => 'equipment'},
      {:component => 'Refrigeration', :param_name => 'refrigeration'},
      {:component => 'Water Use Equipment', :param_name => 'water_use_equipment'},
      {:component => 'HVAC Equipment Losses', :param_name => 'hvac_equipment_loss'},
      {:component => 'Power Generation Equipment', :param_name => 'power_generation_equipment'},
      {:component => 'DOAS Direct to Zone', :param_name => 'doas_direct_to_zone'},
      {:component => 'Infiltration', :param_name => 'infiltration'},
      {:component => 'Zone Ventilation', :param_name => 'zone_ventilation'},
      {:component => 'Interzone Mixing', :param_name => 'interzone_mixing'},
      {:component => 'Roof', :param_name => 'roof'},
      {:component => 'Interzone Ceiling', :param_name => 'interzone_ceiling'},
      {:component => 'Other Roof', :param_name => 'other_roof'},
      {:component => 'Exterior Wall', :param_name  => 'exterior_wall'},
      {:component => 'Interzone Wall', :param_name => 'interzone_wall'},
      {:component => 'Ground Contact Wall', :param_name => 'ground_contact_wall'},
      {:component => 'Other Wall', :param_name => 'other_wall'},
      {:component => 'Exterior Floor', :param_name => 'exterior_floor'},
      {:component => 'Interzone Floor', :param_name => 'interzone_floor'},
      {:component => 'Ground Contact Floor', :param_name => 'ground_contact_floor'},
      {:component => 'Other Floor', :param_name => 'other_floor'},
      {:component => 'Fenestration Conduction', :param_name => 'fenestration_conduction'},
      {:component => 'Fenestration Solar', :param_name => 'fenestration_solar'},
      {:component => 'Opaque Door', :param_name => 'opaque_door'},
      {:component => 'Grand Total', :param_name => 'grand_total'}
  ]

  def initialize(sql_file)
    @sql_file = sql_file
    @peak_load_component_repository = PeakLoadComponentRepository.new(sql_file)
  end

  # @param name [String] the name of the object
  # @param conditioning [String] "heating" or "cooling"
  def find_by_name_and_conditioning(name, conditioning)
    names_query = "SELECT DISTINCT UPPER(ReportForString) From TabularDataWithStrings WHERE TableName == 'Estimated #{conditioning} Peak Load Components'"
    names = @sql_file.execAndReturnVectorOfString(names_query).get

    puts "checking name: " + name.upcase
    puts names

    return unless names.include? name.upcase

    params = {}

    ROW_PARAM_MAP.each do |param|
      params[param[:param_name].to_sym] = @peak_load_component_repository.find(name, conditioning, param[:component])
    end

    PeakLoadComponentTable.new(params)
  end
end