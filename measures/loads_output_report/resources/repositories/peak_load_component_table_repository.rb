require_relative '../peak_load_component_table'
require_relative '../peak_load_component'
# require_relative 'repositories/peak_load_component_repository'

class PeakLoadComponentTableRepository
  attr_accessor :sql_file

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
  COLUMN_PARAM_MAP = [
      {:db_name => 'Sensible - Instant', :param_name => :sensible_instant},
      {:db_name => 'Sensible - Delayed', :param_name => :sensible_delayed},
      {:db_name => 'Sensible - Return Air', :param_name => :sensible_return_air},
      {:db_name => 'Latent', :param_name => :latent},
      {:db_name => 'Total', :param_name => :total},
      {:db_name => '%Grand Total', :param_name => :percent_grand_total},
      {:db_name => 'Related Area', :param_name => :related_area},
      {:db_name => 'Total per Area', :param_name => :total_per_area},
  ]

  def initialize(sql_file)
    self.sql_file = sql_file
  end

  # @param type [String] whether it's a "Zone", "Airloop" or "Facility"
  # @param name [String] the name of the object
  # @param conditioning_type [String] "heating" or "cooling"
  def get(type, name, conditioning_type)
    # params = {:name => name}
    params = {}

    ROW_PARAM_MAP.each do |param|
      params[param[:param_name].to_sym] = get_peak_load_component(type, name, conditioning_type, param[:component])
    end

    PeakLoadComponentTable.new(params)
  end

  private # Does this need to be private?
  # @param type [String] whether it's a "zone", "airloop" or "facility"
  # @param name [String] the name of the object
  # @param conditioning_type [String] "heating" or "cooling"
  # @param component [String] of the type of load (i.e. "People", "Lights", "Equipment")
  def get_peak_load_component(type, name, conditioning_type, component)
    component_query = BASE_QUERY + " WHERE ReportName = '#{type} Component Load Summary' AND TableName =
          'Estimated #{conditioning_type} Peak Load Components' AND UPPER(ReportForString) = '#{name.upcase}' AND RowName = '#{component}'"
    params = {}

    COLUMN_PARAM_MAP.each do |param|
      query = component_query + " AND ColumnName == '#{param[:db_name]}'"
      # puts query
      result = self.sql_file.execAndReturnFirstDouble(query)
      puts result
      if result.is_initialized
        params[param[:param_name]] = result.get
      end
    end

    PeakLoadComponent.new(params)
  end
end