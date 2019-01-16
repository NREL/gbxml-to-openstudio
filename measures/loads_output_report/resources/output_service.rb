require_relative 'repositories/peak_load_component_table_repository'
require_relative 'repositories/peak_condition_table_repository'
require_relative 'repositories/engineering_check_table_repository'
require_relative 'repositories/coil_sizing_detail_repository'
require_relative 'extended_peak_load_component_table'
require_relative 'zone_loads_by_component'
require_relative 'system_checksum'
require_relative 'facility_component_load_summary'

class OutputService
  attr_accessor :sql_file, :peak_load_component_table_repository, :peak_condition_table_repository, :engineering_check_table_repository,
                :coil_sizing_detail_repository

  def initialize(sql_file)
    self.peak_load_component_table_repository = PeakLoadComponentTableRepository.new(sql_file)
    self.peak_condition_table_repository = PeakConditionTableRepository.new(sql_file)
    self.engineering_check_table_repository = EngineeringCheckTableRepository.new(sql_file)
    self.coil_sizing_detail_repository = CoilSizingDetailRepository.new(sql_file)
  end

  def get_zone_loads_by_component(name)
    zone_loads_by_component = ZoneLoadsByComponent.new
    zone_loads_by_component.cooling_peak_load_component_table = self.peak_load_component_table_repository.get('Zone', name, 'Cooling')
    zone_loads_by_component.heating_peak_load_component_table = self.peak_load_component_table_repository.get('Zone', name, 'Heating')
    zone_loads_by_component.cooling_peak_condition_table_repository = self.peak_condition_table_repository.get('Zone', name, 'Cooling')
    zone_loads_by_component.heating_peak_condition_table_repository = self.peak_condition_table_repository.get('Zone', name, 'Heating')
    zone_loads_by_component.cooling_engineering_check_table = self.engineering_check_table_repository.get('Zone', name, 'Cooling')
    zone_loads_by_component.heating_engineering_check_table = self.engineering_check_table_repository.get('Zone', name, 'Heating')

    zone_loads_by_component
  end

  def get_system_checksum(system_name, cooling_coil_name, heating_coil_name)
    system_checksum = SystemChecksum.new
    extended_cooling_peak_load_component_table = SystemChecksumPeakLoadComponentTable.new(self.peak_load_component_table_repository.get('AirLoop', system_name, 'Cooling'))
    extended_heating_peak_load_component_table = SystemChecksumPeakLoadComponentTable.new(self.peak_load_component_table_repository.get('AirLoop', system_name, 'Heating'))
    system_checksum.cooling_peak_load_component_table = extended_cooling_peak_load_component_table
    system_checksum.heating_peak_load_component_table = extended_heating_peak_load_component_table
    system_checksum.cooling_peak_condition_table_repository = self.peak_condition_table_repository.get('AirLoop', system_name, 'Cooling')
    system_checksum.heating_peak_condition_table_repository = self.peak_condition_table_repository.get('AirLoop', system_name, 'Heating')
    system_checksum.cooling_engineering_check_table = self.engineering_check_table_repository.get('AirLoop', system_name, 'Cooling')
    system_checksum.heating_engineering_check_table = self.engineering_check_table_repository.get('AirLoop', system_name, 'Heating')

    # Todo: Set coil sizing details for coils
    system_checksum.cooling_coil_sizing_detail = @coil_sizing_detail_repository.get(coil_name)
    system_checksum.heating_coil_sizing_detail = @coil_sizing_detail_repository.get(coil_name)

    system_checksum.calculate_additional_results
    system_checksum
  end

  def get_facility_component_load_summary
    facility_component_load_summary = FacilityComponentLoadSummary.new
    name = 'Facility'
    facility_component_load_summary.cooling_peak_load_component_table = self.peak_load_component_table_repository.get('Facility', name, 'Cooling')
    facility_component_load_summary.heating_peak_load_component_table = self.peak_load_component_table_repository.get('Facility', name, 'Heating')
    facility_component_load_summary.cooling_peak_condition_table_repository = self.peak_condition_table_repository.get('Facility', name, 'Cooling')
    facility_component_load_summary.heating_peak_condition_table_repository = self.peak_condition_table_repository.get('Facility', name, 'Heating')
    facility_component_load_summary.cooling_engineering_check_table = self.engineering_check_table_repository.get('Facility', name, 'Cooling')
    facility_component_load_summary.heating_engineering_check_table = self.engineering_check_table_repository.get('Facility', name, 'Heating')

    facility_component_load_summary
  end

  def get_design_psychrometric(name)

  end

  def get_system_component_summary

  end
end