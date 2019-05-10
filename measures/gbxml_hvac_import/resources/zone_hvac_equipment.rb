class ZoneHVACEquipment < HVACObject
  attr_accessor :zone

  def add_zone(zone)
    self.zone = zone
  end

  # This can be a factory based on the zoneHVACEquipmentType
  def self.equipment_type_mapping(model_manager, xml)
    equipment_type = xml.attributes['zoneHVACEquipmentType']
    unless equipment_type.nil?
      case equipment_type
      when 'VAVBox'
        VAVBox.create_from_xml(model_manager, xml)
      when 'CAVBox'
        CAVBox.create_from_xml(model_manager, xml)
      when 'PackagedTerminalAirConditioner'
        PTAC.create_from_xml(model_manager, xml)
      when 'PackagedTerminalHeatPump'
        PTHP.create_from_xml(model_manager, xml)
      when 'UnitHeater'
        UnitHeater.create_from_xml(model_manager, xml)
      when 'UnitVentilator'
        UnitVentilator.create_from_xml(model_manager, xml)
      when 'BaseBoardConvective'
        BaseboardConvective.create_from_xml(model_manager, xml)
      when 'BaseBoardRadiant'
        BaseboardRadiant.create_from_xml(model_manager, xml)
      when 'FourPipeFanCoil'
        FPFC.create_from_xml(model_manager, xml)
      when 'ParallelFanPoweredBox'
        PFPB.create_from_xml(model_manager, xml)
      when 'SeriesFanPoweredBox'
        SFPB.create_from_xml(model_manager, xml)
      when 'WaterSourceHeatPump'
        WSHP.create_from_xml(model_manager, xml)
      when 'ChilledBeamPassive'
        PCB.create_from_xml(model_manager, xml)
      when 'ChilledBeamActive'
        ACB.create_from_xml(model_manager, xml)
      when 'RadiantPanel'
        RadiantPanel.create_from_xml(model_manager, xml)
      when 'VRFFanCoil'
        VRFFanCoilUnit.create_from_xml(model_manager, xml)
      end
    end
  end
end