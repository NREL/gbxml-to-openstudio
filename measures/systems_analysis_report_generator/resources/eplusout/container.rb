module EPlusOut
  def self.container(sql_file)
    container = Canister.new

    container.register(:sql_gateway) { Gateways::SqlGateway.new(sql_file) }
    container.register(:coil_sizing_details) { |c| Relations::CoilSizingDetails.new(c.sql_gateway) }
    container.register(:cooling_peak_conditions) { |c| Relations::CoolingPeakConditions.new(c.sql_gateway) }
    container.register(:heating_peak_conditions) { |c| Relations::HeatingPeakConditions.new(c.sql_gateway) }
    container.register(:engineering_check_for_coolings) { |c| Relations::EngineeringCheckForCoolings.new(c.sql_gateway) }
    container.register(:engineering_check_for_heatings) { |c| Relations::EngineeringCheckForHeatings.new(c.sql_gateway) }
    container.register(:estimated_cooling_peak_load_component_tables) { |c| Relations::EstimatedCoolingPeakLoadComponentTables.new(c.sql_gateway) }
    container.register(:estimated_heating_peak_load_component_tables) { |c| Relations::EstimatedHeatingPeakLoadComponentTables.new(c.sql_gateway) }
    container.register(:locations) { |c| Relations::Locations.new(c.sql_gateway) }

    container
  end
end