require_relative 'jsonable'

class SystemComponentSummary < JSONable
  attr_accessor :cooling_coils, :heating_coils, :load_air_flows, :fans
end
