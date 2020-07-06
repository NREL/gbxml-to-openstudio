# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'rexml/document'
require 'rexml/xpath'

# require all .rb files in resources folder
Dir[File.dirname(__FILE__) + '/resources/*.rb'].each { |file| require file }

# start the measure
class AdvancedImportGbxml < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Advanced Import Gbxml'
  end

  # human readable description
  def description
    return 'This measure will bring in additional gbXML data beyond what comes in with the basic OpenStudio gbXML import.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This measure expects GbXMLReverseTranslator to already have been run on the model. This measure parses the XML and translates additional gbXML objects to OSM.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # the name of the space to add to the model
    gbxml_file_name = OpenStudio::Measure::OSArgument.makeStringArgument("gbxml_file_name", true)
    gbxml_file_name.setDisplayName("gbXML filename")
    gbxml_file_name.setDescription("Filename or full path to gbXML file.")
    args << gbxml_file_name

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    unless runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    gbxml_file_name = runner.getStringArgumentValue("gbxml_file_name", user_arguments)

    # check the space_name for reasonableness
    if gbxml_file_name.empty?
      runner.registerError("Empty gbXML filename was entered.")
      return false
    end

    # find the gbXML file
    path = runner.workflow.findFile(gbxml_file_name)
    if path.empty?
      runner.registerError("Could not find gbXML filename '#{gbxml_file_name}'.")
      return false
    end
    path = path.get

    # report initial condition of model
    runner.registerInitialCondition("The building started with #{model.objects.size} model objects.")

    # read in and parse xml using using rexml
    xml_string = File.read(path.to_s)
    gbxml_doc = REXML::Document.new(xml_string)

    units = gbxml_doc.elements['gbXML'].attributes['useSIUnitsForResults'] == "true" ? "SI" : "IP"
    runner.setUnitsPreference(units)

    # test looking for building area
    gbxml_area = gbxml_doc.elements["/gbXML/Campus/Building/Area"]
    runner.registerInfo("the gbXML has an area of #{gbxml_area.text.to_f}.")

    # get building type
    building_type = gbxml_doc.elements["/gbXML/Campus/Building"].attributes['buildingType']

    # set location parameters
    # @type [OpenStudio::Model::Site] site
    site = model.getSite
    location_element = gbxml_doc.elements["/gbXML/Campus/Location"]
    site.setLongitude(location_element.elements["Longitude"].text.to_f) unless location_element.elements["Longitude"].nil?
    site.setLatitude(location_element.elements["Latitude"].text.to_f) unless location_element.elements["Latitude"].nil?
    site.setName(location_element.elements["Name"].text) unless location_element.elements["Name"].nil?
    site.setTimeZone(model.getWeatherFile.timeZone)

    length_unit = gbxml_doc.elements['gbXML'].attributes['lengthUnit']
    unless location_element.elements["Elevation"].nil?
      elevation = location_element.elements["Elevation"].text.to_f
      elevation = OpenStudio.convert(elevation, "ft", "m").get if length_unit == "Feet"
      site.setElevation(elevation)
    end

    # Assign construction absorptance
    materials_set = Set.new
    gbxml_doc.elements.each('gbXML/Construction') do |construction|
      absorptance = construction.elements['Absorptance'].text.to_f unless construction.elements['Absorptance'].nil?
      construction_name = construction.elements['Name'].text unless construction.elements['Name'].nil?

      next unless absorptance and construction_name

      absorptance = OpenStudio::OptionalDouble.new(absorptance)
      os_construction = model.getConstructionByName(construction_name)

      next unless os_construction.is_initialized
      os_construction = os_construction.get

      outer_material = os_construction.layers[0]

      if materials_set.include? outer_material
        outer_material = outer_material.clone.to_OpaqueMaterial.get
        os_construction.setLayer(0, outer_material)
      end

      outer_material.to_OpaqueMaterial.get.setSolarAbsorptance(absorptance)
      materials_set.add(outer_material)
    end

    # create hash used for importing
    advanced_inputs = {}
    advanced_inputs[:building_type] = building_type
    advanced_inputs[:spaces] = {}
    advanced_inputs[:zones] = {}
    advanced_inputs[:schedule_sets] = {} # key is "light|equip|people|"
    advanced_inputs[:schedules] = {}
    advanced_inputs[:week_schedules] = {}
    advanced_inputs[:day_schedules] = {}
    advanced_inputs[:people_num] = {} # osm gen code should use default if this isn't found
    advanced_inputs[:people_defs] = {}
    advanced_inputs[:light_defs] = {}
    advanced_inputs[:equip_defs] = {}

    gbxml_doc.elements.each('gbXML/Campus/Building/Space') do |element|
      name = element.elements['Name']

      # find or create schedule_set key in hash
      target_sch_set_key = "#{element.attributes['lightScheduleIdRef']}|#{element.attributes['equipmentScheduleIdRef']}|#{element.attributes['peopleScheduleIdRef']}"
      unless advanced_inputs[:schedule_sets].has_key?(target_sch_set_key)
        if not target_sch_set_key == "||"
          light_sch = element.attributes['lightScheduleIdRef']
          elec_sch = element.attributes['equipmentScheduleIdRef']
          occ_sch = element.attributes['peopleScheduleIdRef']
          advanced_inputs[:schedule_sets][target_sch_set_key] = {}
          advanced_inputs[:schedule_sets][target_sch_set_key][:light_schedule_id_ref] = light_sch
          advanced_inputs[:schedule_sets][target_sch_set_key][:equipment_schedule_id_ref] = elec_sch
          advanced_inputs[:schedule_sets][target_sch_set_key][:people_schedule_id_ref] = occ_sch
        end
      end

      # create hash entry for space with attributes
      advanced_inputs[:spaces][element.attributes['id']] = {}
      unless target_sch_set_key == "||"
        advanced_inputs[:spaces][element.attributes['id']][:sch_set] = target_sch_set_key
      end
      unless element.attributes['zoneIdRef'].nil?
        advanced_inputs[:spaces][element.attributes['id']][:zone_id_ref] = element.attributes['zoneIdRef']
      end
      unless element.attributes['conditionType'].nil?
        advanced_inputs[:spaces][element.attributes['id']][:condition_type] = element.attributes['conditionType']
      end
      unless element.elements['Name'].nil?
        advanced_inputs[:spaces][element.attributes['id']][:name] = element.elements['Name'].text
      end

      # Populate hash for space load instances for people, lights, and electric equipment.
      # Don't duplicate load definitions if an equivalent one has already been made.

      # gather lights
      light_element = element.elements['LightPowerPerArea']
      unless light_element.nil?
        light_power_per_area = light_element.text.to_f
        light_power_per_area = OpenStudio.convert(light_power_per_area, "W/m^2", "W/ft^2").get if light_element.attributes['unit'] == "WattPerSquareMeter"
        unless advanced_inputs[:light_defs].has_key?(light_power_per_area)
          advanced_inputs[:light_defs][light_power_per_area] = "adv_import_light_#{advanced_inputs[:light_defs].size}"
        end
        advanced_inputs[:spaces][element.attributes['id']][:light_defs] = light_power_per_area
      end

      # gather electric equipment
      equipment_element = element.elements['EquipPowerPerArea']
      unless equipment_element.nil?
        equip_power_per_area = equipment_element.text.to_f
        equip_power_per_area = OpenStudio.convert(equip_power_per_area, "W/m^2", "W/ft^2").get if equipment_element.attributes['unit'] == "WattPerSquareMeter"
        unless advanced_inputs[:equip_defs].has_key?(equip_power_per_area)
          advanced_inputs[:equip_defs][equip_power_per_area] = "adv_import_elec_equip_#{advanced_inputs[:equip_defs].size}"
        end
        advanced_inputs[:spaces][element.attributes['id']][:equip_defs] = equip_power_per_area
      end

      # gather people
      # unlike lights and equipment, there are multiple people objects in the space to inspect
      space_people_attributes = {}
      element.elements.each('PeopleHeatGain') do |people_heat_gain|
        unit = people_heat_gain.attributes['unit']
        heat_gain_type = people_heat_gain.attributes['heatGainType']
        heat_gain = unit == "BtuPerHourPerson" ? people_heat_gain.text.to_f : OpenStudio.convert(people_heat_gain.text.to_f, "W", "Btu/h").get
        space_people_attributes["people_heat_gain_#{heat_gain_type.downcase}"] = heat_gain
      end
      unless element.elements['PeopleNumber'].nil?
        space_people_attributes[:people_number] = element.elements['PeopleNumber'].text.to_f
      end
      unless advanced_inputs[:people_defs].has_key?(space_people_attributes) && space_people_attributes.size > 0
        advanced_inputs[:people_defs][space_people_attributes] = "adv_import_people_#{advanced_inputs[:people_defs].size}"
      end
      if space_people_attributes.size > 0
        advanced_inputs[:spaces][element.attributes['id']][:people_defs] = space_people_attributes
      end

      # gather infiltration
      infiltration_def = { infiltration_flow_per_space: nil,                 # cfm
                           infiltration_flow_per_space_area: nil,            # cfm/ft2
                           infiltration_flow_per_exterior_surface_area: nil, # cfm/ft2
                           infiltration_flow_per_exterior_wall_area: nil,    # cfm/ft2
                           infiltration_flow_air_changes_per_hour: nil }     # 1/h
      if !element.elements['InfiltrationFlowPerArea'].nil?
        infiltration_element = element.elements['InfiltrationFlowPerArea']
        infiltration = infiltration_element.text.to_f
        infiltration = OpenStudio.convert(infiltration, "L/s*m^2", "cfm/ft^2").get if infiltration_element.attributes['unit'] == "LPerSecPerSquareM"
        infiltration_def[:infiltration_flow_per_exterior_wall_area] = infiltration
      end

      advanced_inputs[:spaces][element.attributes['id']][:infiltration_def] = infiltration_def

      # gather ventilation
      ventilation_def = { ventilation_flow_per_person: 0.0,            # cfm
                          ventilation_flow_per_area: 0.0,              # cfm/ft2
                          ventilation_flow_per_space: 0.0,             # cfm
                          ventilation_flow_air_changes_per_hour: 0.0 } # 1/h
      unless element.attributes['outdoorAirflowMethod'].nil?
        ventilation_def[:outdoor_airflow_method] = element.attributes['outdoorAirflowMethod']
      end
      if !element.elements['OAFlowPerPerson'].nil?
        ventilation_element = element.elements['OAFlowPerPerson']
        ventilation = ventilation_element.text.to_f
        ventilation = OpenStudio.convert(ventilation, "L/s", "cfm").get if ventilation_element.attributes['unit'] == "LPerSec"
        ventilation_def[:ventilation_flow_per_person] = ventilation
      end
      if !element.elements['OAFlowPerArea'].nil?
        ventilation_element = element.elements['OAFlowPerArea']
        ventilation = ventilation_element.text.to_f
        ventilation = OpenStudio.convert(ventilation, "L/s*m^2", "cfm/ft^2").get if ventilation_element.attributes['unit'] == "LPerSecPerSquareM"
        ventilation_def[:ventilation_flow_per_area] = ventilation
      end
      if !element.elements['OAFlowPerSpace'].nil?
        ventilation_element = element.elements['OAFlowPerSpace']
        ventilation = ventilation_element.text.to_f
        ventilation = OpenStudio.convert(ventilation, "L/s", "cfm").get if ventilation_element.attributes['unit'] == "LPerSec"
        ventilation_def[:ventilation_flow_per_space] = ventilation
      end
      if !element.elements['AirChangesPerHour'].nil?
        ventilation_def[:ventilation_flow_air_changes_per_hour] = element.elements['AirChangesPerHour'].text.to_f
      end
      advanced_inputs[:spaces][element.attributes['id']][:ventilation_def] = ventilation_def

    # Hard code space volumes as geometry may not be clean enough to compute all the time.
      id_element = element.elements['CADObjectId']
      id = id_element ? id_element.text : false

      model.getSpaces().each do |space|

        optional_id = space.additionalProperties.getFeatureAsString('CADObjectId')

        if optional_id.is_initialized && id

          # check if OS space ID equals gbXML space ID
          if id == optional_id.get

            # get space volume from gbXML
            volume = element.elements['Volume']

            # see if volume elements exists
            unless volume.nil?
              volume = volume.text.to_f

              # check units and adjust if needed
              volume_unit = gbxml_doc.elements['gbXML'].attributes['volumeUnit']
              volume = OpenStudio.convert(volume, "ft^3", "m^3").get if volume_unit == "CubicFeet"

              thermal_zone = space.thermalZone.get
              original_volume = thermal_zone.volume

              # Add volume to existing or set for the first time
              if original_volume.is_initialized
                original_volume = original_volume.get
                thermal_zone.setVolume(original_volume + volume)
              else
                thermal_zone.setVolume(volume)
              end
            end
          end
        end
      end
    end

    # note, schedules and schedule sets will be generated as used when looping through spaces
    gbxml_doc.elements.each('gbXML/Schedule') do |element|
      name = element.elements['Name']
      # add schedules to hash with array of week schedules
      sch_week = element.elements['YearSchedule/WeekScheduleId'].attributes['weekScheduleIdRef']
      advanced_inputs[:schedules][element.attributes['id']] = {'name' => name.text, 'sch_week' => sch_week}
    end

    runner.registerInfo("removing ScheduleYear, ScheduleWeek, and ScheduleDay, objects. That data will be re-imported as ScheduleRuleset")
    model.getScheduleYears.each { |year| year.remove }
    model.getScheduleWeeks.each { |week| week.remove }
    model.getScheduleDays.each { |day| day.remove }

    # note, schedules and schedule sets will be generated as used when looping through spaces
    gbxml_doc.elements.each('gbXML/WeekSchedule') do |element|
      name = element.elements['Name']
      # add schedules to hash with array of week schedules
      day_types = {}
      element.elements.each do |day_type|
        next unless day_type.attributes.has_key?('dayType')
        day_types[day_type.attributes['dayType']] = day_type.attributes['dayScheduleIdRef']
      end
      advanced_inputs[:week_schedules][element.attributes['id']] = day_types
    end

    # note, schedules and schedule sets will be generated as used when looping through spaces
    gbxml_doc.elements.each('gbXML/DaySchedule') do |element|
      name = element.elements['Name']

      # add schedules to hash with array of week schedules
      hourly_values = []
      element.elements.each('ScheduleValue') do |hour|
        hourly_values << hour.text.to_f
      end
      advanced_inputs[:day_schedules][element.attributes['id']] = hourly_values
    end

    gbxml_doc.elements.each('gbXML/Zone') do |element|
      name = element.elements['Name']

      # create hash entry for space with attributes
      advanced_inputs[:zones][element.attributes['id']] = {}
      unless element.elements['Name'].nil?
        advanced_inputs[:zones][element.attributes['id']][:name] = element.elements['Name'].text
      end

      # store DesignHeatT and DesignCoolT
      unless element.elements['DesignHeatT'].nil?
        design_heat_t_element = element.elements['DesignHeatT']
        design_heat_t = design_heat_t_element.text.to_f
        design_heat_t = OpenStudio.convert(design_heat_t, "C", "F").get if design_heat_t_element.attributes['unit'] == "C"
        advanced_inputs[:zones][element.attributes['id']][:design_heat_t] = design_heat_t
      end
      unless element.elements['DesignCoolT'].nil?
        design_cool_t_element = element.elements['DesignCoolT']
        design_cool_t = design_cool_t_element.text.to_f
        design_cool_t = OpenStudio.convert(design_cool_t, "C", "F").get if design_cool_t_element.attributes['unit'] == "C"
        advanced_inputs[:zones][element.attributes['id']][:design_cool_t] = design_cool_t
      end

      unless element.elements['DesignHeatRH'].nil?
        design_heat_rh_element = element.elements['DesignHeatRH']
        design_heat_rh = design_heat_rh_element.text.to_f
        advanced_inputs[:zones][element.attributes['id']][:design_heat_rh] = design_heat_rh
      end
      unless element.elements['DesignCoolRH'].nil?
        design_cool_rh_element = element.elements['DesignCoolRH']
        design_cool_rh = design_cool_rh_element.text.to_f
        advanced_inputs[:zones][element.attributes['id']][:design_cool_rh] = design_cool_rh
      end

    end

    # create model objects from hash
    OsLib_AdvImport.add_objects_from_adv_import_hash(runner, model, advanced_inputs)

    # cleanup fenestration that may be too large (need to confirm how doors and glass doors are addressed)
    OsLib_AdvImport.assure_fenestration_inset(runner, model)

    # report final condition of model
    runner.registerFinalCondition("The building finished with #{model.objects.size} model objects.")

    return true
  end
end

# register the measure to be used by the application
AdvancedImportGbxml.new.registerWithApplication