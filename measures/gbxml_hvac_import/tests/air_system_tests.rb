require 'openstudio'
require 'openstudio-standards'
require_relative '../resources/air_system/air_system'
require_relative '../resources/chilled_water_loop/chilled_water_loop'
require_relative '../resources/condenser_loop/condenser_loop'
require_relative '../resources/hot_water_loop/hot_water_loop'
require_relative '../resources/model/helpers'
require_relative '../resources/zone_hvac_equipment/zone_hvac_equipment'
require_relative '../resources/zone/zone'

class AirSystemTests
  def self.test1
    file = File.open('/Users/npflaum/Documents/GitHub/gbxml-to-openstudio/gbxmls/RheaExportAnalyticalSystems/RheaExportVariableAirVolumeBox.xml')
    gbxml_doc = REXML::Document.new(file)


    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    path = OpenStudio::Path.new('/Users/npflaum/Documents/GitHub/gbxml-to-openstudio/gbxmls/RheaExportAnalyticalSystems/RheaExportVariableAirVolumeBox.xml')
    new_model = translator.loadModel(path)
    model = new_model.get
    std = Standard.build('90.1-2013')

    gbxml_doc.elements.each("gbXML/HydronicLoop[@loopType='CondenserWater']") do |element|
      CondenserLoop.create_cw_loop_from_xml(model, std, element)
    end

    gbxml_doc.elements.each("gbXML/HydronicLoop[@loopType='PrimaryChilledWater']") do |element|
      ChilledWaterLoop.create_chw_loop_from_xml(model, std, element)
    end

    gbxml_doc.elements.each("gbXML/HydronicLoop[@loopType='HotWater']") do |element|
      HotWaterLoop.create_hw_loop_from_xml(model, std, element)
    end

    gbxml_doc.elements.each("gbXML/AirSystem") do |element|
      AirSystem.create_air_system_from_xml(model, std, element)
    end

    gbxml_doc.elements.each("gbXML/ZoneHVACEquipment") do |element|
      ZoneHVACEquipment.equipment_type_mapping(model, std, element)
    end

    gbxml_doc.elements.each("gbXML/Zone") do |element|
      Zone.map_to_zone_hvac_equipment(model, element)
    end

    Helpers.clean_up_model(model)
    path = OpenStudio::Path.new(File.expand_path(File.join(File.dirname(__FILE__ ), '../output_models/test1.osm')))
    model.save(path, true)

  end
end

AirSystemTests.test1
