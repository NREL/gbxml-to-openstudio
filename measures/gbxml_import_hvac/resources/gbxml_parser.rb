class GBXMLParser
  attr_accessor :gbxml, :hw_loops, :chw_loops, :cw_loops, :vrf_loops, :air_systems, :zone_hvac_equipments, :zones

  def initialize(path)
    xml_file = File.read(path.to_s)
    self.gbxml = REXML::Document.new(xml_file)
    self.hw_loops = self.gbxml.get_elements("gbXML/HydronicLoop[@loopType='HotWater']")
    self.chw_loops = self.gbxml.get_elements("gbXML/HydronicLoop[@loopType='PrimaryChilledWater']")
    self.cw_loops = self.gbxml.get_elements("gbXML/HydronicLoop[@loopType='CondenserWater']")
    self.vrf_loops = self.gbxml.get_elements("gbXML/HydronicLoop[@loopType='VRFLoop']")
    self.air_systems = self.gbxml.get_elements("gbXML/AirSystem")
    self.zone_hvac_equipments = self.gbxml.get_elements("gbXML/ZoneHVACEquipment")
    self.zones = self.gbxml.get_elements("gbXML/Zone")
  end

end