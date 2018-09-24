class ZoneHVACEquipment
  # This can be a factory based on the zoneHVACEquipmentType
  def self.equipment_type_mapping(xml)
    equipment_type = xml.attributes['zoneHVACEquipmentType']
    unless equipment_type.nil?
      case equipment_type
      when 'VAVBox'
        VAVBox.create_from_xml(xml)
      when 'CAVBox'
        CAVBox.create_from_xml(xml)
      when 'PackagedTerminalAirConditioner'
        PTAC.create_from_xml(xml)
      when 'PackagedTerminalHeatPump'
        PTHP.create_from_xml(xml)
      when 'UnitHeater'
        UnitHeater.create_from_xml(xml)
      when 'UnitVentilator'
        UnitVentilator.create_from_xml(xml)
      when 'BaseBoardConvective'
        BaseboardConvective.create_from_xml(xml)
      when 'BaseBoardRadiant'
        BaseboardRadiant.create_from_xml(xml)
      when 'FourPipeFanCoil'
        FPFC.create_from_xml(xml)
      when 'ParallelFanPoweredBox'
        PFPB.create_from_xml(xml)
      when 'SeriesFanPoweredBox'
        SFPB.create_from_xml(xml)
      when 'WaterSourceHeatPump'
        WSHP.create_from_xml(xml)
      end
    end
  end
end