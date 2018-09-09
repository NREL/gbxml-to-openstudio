require_relative '../gbxml_parser/gbxml_parser'
require_relative '../hot_water_loop/hot_water_loop'
require_relative '../condenser_loop/condenser_loop'
require_relative '../chilled_water_loop/chilled_water_loop'
require_relative '../air_system/air_system'
require_relative '../vav_box/vav_box'
require_relative '../zone_hvac_equipment/zone_hvac_equipment'

class ModelManager
  attr_accessor :gbxml_parser, :model, :cw_loops, :hw_loops, :chw_loops, :air_systems, :zone_hvac_equipments, :zones,
                :os_cw_loops, :os_hw_loops, :os_chw_loops, :os_air_systems

  def initialize(model, gbxml_path)
    self.model = model
    self.gbxml_parser = GBXMLParser.new(gbxml_path)
    self.cw_loops = {}
    self.hw_loops = {}
    self.chw_loops = {}
    self.air_systems = {}
    self.zone_hvac_equipments = {}
    self.zones = {}

    self.gbxml_parser.cw_loops.each do |cw_loop|
      condenser_loop = CondenserLoop.create_from_xml(cw_loop)
      self.cw_loops[condenser_loop.id] = condenser_loop
    end

    self.gbxml_parser.hw_loops.each do |hw_loop|
      hot_water_loop = HotWaterLoop.create_from_xml(hw_loop)
      self.hw_loops[hot_water_loop.id] = hot_water_loop
    end

    self.gbxml_parser.chw_loops.each do |chw_loop|
       chilled_water_loop = ChilledWaterLoop.create_from_xml(chw_loop)
       self.chw_loops[chilled_water_loop.id] = chilled_water_loop
    end

    self.gbxml_parser.air_systems.each do |air_sys|
      air_system = AirSystem.create_from_xml(air_sys)
      self.air_systems[air_system.id] = air_system
    end

    self.gbxml_parser.zone_hvac_equipments.each do |zone_hvac_equipment|
      equipment = ZoneHVACEquipment.equipment_type_mapping(zone_hvac_equipment)
      self.zone_hvac_equipments[equipment.id] = equipment
    end

    self.gbxml_parser.zones.each do |zone|
      zone = Zone.create_from_xml(zone)
      self.zones[zone.id] = zone
    end

    self.cw_loops.values.each do |cw_loop|
      cw_loop.build(self)
    end

    self.hw_loops.values.each do |hw_loop|
      hw_loop.build(self)
    end

    self.chw_loops.values.each do |chw_loop|
      chw_loop.build(self)
    end

    self.air_systems.values.each do |air_system|
      air_system.build(self)
    end

    self.zone_hvac_equipments.values.each do |zone_hvac_equipment|
      zone_hvac_equipment.build(self)
    end

    self.zones.values.each do |zone|
      zone.build(self)
    end

    # self.gbxml_parser.air_systems.each do |hw_loop|
    #   self.hw_loops << HotWaterLoop.create_hw_loop_from_xml(model, hw_loop)
    # end
    #
    # self.gbxml_parser.zone_hvac_equipments.each do |hw_loop|
    #   self.hw_loops << HotWaterLoop.create_hw_loop_from_xml(model, hw_loop)
    # end
    #
    # self.gbxml_parser.zones.each do |hw_loop|
    #   self.hw_loops << HotWaterLoop.create_hw_loop_from_xml(model, hw_loop)
    # end


  end
end