module EPlusOut
  module Models
    Location = Struct.new(:name, :location_name, :latitude, :longitude, :time_zone_number, :elevation,
                          :standard_pressure_at_elevation, :standard_rhoair_at_elevation) do
      include Models::Model
    end
  end
end