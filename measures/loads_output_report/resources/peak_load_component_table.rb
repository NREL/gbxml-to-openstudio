require_relative 'jsonable'

class PeakLoadComponentTable < JSONable
  attr_accessor :people, :lights, :equipment, :refrigeration, :water_use_equipment, :hvac_equipment_loss,
                :power_generation_equipment, :doas_direct_to_zone, :infiltration, :zone_ventilation, :interzone_mixing,
                :roof, :interzone_ceiling, :other_roof, :exterior_wall, :interzone_wall, :ground_contact_wall,
                :other_wall, :exterior_floor, :interzone_floor, :ground_contact_floor, :other_floor,
                :fenestration_conduction, :fenestration_solar, :opaque_door, :grand_total

  def initialize(options)
    @people = options[:people]
    @lights = options[:lights]
    @equipment = options[:equipment]
    @refrigeration = options[:refrigeration]
    @water_use_equipment = options[:water_use_equipment]
    @hvac_equipment_loss = options[:hvac_equipment_loss]
    @power_generation_equipment = options[:power_generation_equipment]
    @doas_direct_to_zone = options[:doas_direct_to_zone]
    @infiltration = options[:infiltration]
    @zone_ventilation = options[:zone_ventilation]
    @interzone_mixing = options[:interzone_mixing]
    @roof = options[:roof]
    @interzone_ceiling = options[:interzone_ceiling]
    @other_roof = options[:other_roof]
    @exterior_wall = options[:exterior_wall]
    @interzone_wall = options[:interzone_wall]
    @ground_contact_wall = options[:ground_contact_wall]
    @other_wall = options[:other_wall]
    @exterior_floor = options[:exterior_floor]
    @interzone_floor = options[:interzone_floor]
    @ground_contact_floor = options[:ground_contact_floor]
    @other_floor = options[:other_floor]
    @fenestration_conduction = options[:fenestration_conduction]
    @fenestration_solar = options[:fenestration_solar]
    @opaque_door = options[:opaque_door]
    @grand_total = options[:grand_total]
  end
end