# require 'openstudio'
# puts File.join(__dir__, '../**/*.rb')
# puts File.expand_path(File.join(__dir__, '../**/*.rb'))
# require_path = File.expand_path(File.join(__dir__, '../**/*.rb'))
#
# # Dir["../**/*.rb"]
# Dir[require_path].each do |file|
#   next if file == __FILE__ # don't reload this file
#   require file
# end

class ModelManager
  attr_accessor :gbxml_parser, :model, :cw_loops, :hw_loops, :chw_loops, :vrf_loops, :air_systems, :zone_hvac_equipments, :zones,
                :os_cw_loops, :os_hw_loops, :os_chw_loops, :os_air_systems

  def initialize(model, gbxml_path)

    self.model = model
    self.gbxml_parser = GBXMLParser.new(gbxml_path)
    self.cw_loops = {}
    self.hw_loops = {}
    self.chw_loops = {}
    self.vrf_loops = {}
    self.air_systems = {}
    self.zone_hvac_equipments = {}
    self.zones = {}
  end

  def load_gbxml
    self.gbxml_parser.cw_loops.each do |cw_loop|
      condenser_loop = CondenserLoop.create_from_xml(self, cw_loop)
      self.cw_loops[condenser_loop.id] = condenser_loop
    end

    self.gbxml_parser.hw_loops.each do |hw_loop|
      hot_water_loop = HotWaterLoop.create_from_xml(self, hw_loop)
      self.hw_loops[hot_water_loop.id] = hot_water_loop
    end

    self.gbxml_parser.chw_loops.each do |chw_loop|
       chilled_water_loop = ChilledWaterLoop.create_from_xml(self, chw_loop)
       self.chw_loops[chilled_water_loop.id] = chilled_water_loop
    end

    self.gbxml_parser.vrf_loops.each do |vrf_gbxml_loop|
      vrf_loop = VRFCondenser.create_from_xml(self, vrf_gbxml_loop)
      self.vrf_loops[vrf_loop.id] = vrf_loop
    end

    self.gbxml_parser.air_systems.each do |air_sys|
      air_system = AirSystem.create_from_xml(self, air_sys)
      self.air_systems[air_system.id] = air_system
    end

    self.gbxml_parser.zone_hvac_equipments.each do |zone_hvac_equipment|
      equipment = ZoneHVACEquipment.equipment_type_mapping(self, zone_hvac_equipment)
      if equipment
        self.zone_hvac_equipments[equipment.id] = equipment
      end
    end

    self.gbxml_parser.zones.each do |zone|
      zone = Zone.create_from_xml(self, zone)
      self.zones[zone.id] = zone
    end
  end

  def resolve_references
    self.zones.values.map(&:resolve_references)
    self.zone_hvac_equipments.values.map(&:resolve_references)
    self.air_systems.values.map(&:resolve_references)
    self.vrf_loops.values.map(&:resolve_references)
    self.chw_loops.values.map(&:resolve_references)
  end

  def resolve_read_relationships
    self.cw_loops.values.map(&:resolve_read_relationships)
    self.hw_loops.values.map(&:resolve_read_relationships)
    self.chw_loops.values.map(&:resolve_read_relationships)
    self.vrf_loops.values.map(&:resolve_read_relationships)
    self.air_systems.values.map(&:resolve_read_relationships)
    self.zone_hvac_equipments.values.map(&:resolve_read_relationships)
  end

  def build
    self.cw_loops.values.map(&:build)
    self.hw_loops.values.map(&:build)
    self.chw_loops.values.map(&:build)
    self.vrf_loops.values.map(&:build)
    self.air_systems.values.map(&:build)
    self.zone_hvac_equipments.values.map(&:build)
    self.zones.values.map(&:build)
  end

  def connect
    self.zone_hvac_equipments.values.map(&:connect)
  end

  def post_build
    self.zone_hvac_equipments.values.map(&:post_build)
    self.chw_loops.values.map(&:post_build)
    self.vrf_loops.values.map(&:post_build)
    self.air_systems.values.map(&:post_build)
  end
end