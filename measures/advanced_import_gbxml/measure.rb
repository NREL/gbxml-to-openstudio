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
    if !runner.validateUserArguments(arguments(model), user_arguments)
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

    # test looking for building area
    gbxml_area = gbxml_doc.elements["/gbXML/Campus/Building/Area"]
    runner.registerInfo("the gbXML has an area of #{gbxml_area.text.to_f}.")

=begin
    puts "**Looping through surfaces"
    gbxml_doc.elements.each('gbXML/Campus/Surface') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "Surface #{element.attributes['id']} does not have a name"
      end
    end
=end

    # create hash used for importing
    advanced_inputs = {}
    advanced_inputs[:spaces] = {}
    advanced_inputs[:schedule_sets] = {} # key is "light|equip|people|"
    advanced_inputs[:schedules] = {}
    advanced_inputs[:week_schedules] = {}
    advanced_inputs[:day_schedules] = {}
    advanced_inputs[:people_num] = {} # osm gen code should use default if this isn't found
    advanced_inputs[:people_defs] = {}
    advanced_inputs[:light_defs] = {}
    advanced_inputs[:equip_defs] = {}

    puts "**Looping through spaces"
    gbxml_doc.elements.each('gbXML/Campus/Building/Space') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "Space #{element.attributes['id']} does not have a name"
      end

      # find or create schedule_set key in hash
      target_sch_set_key = "#{element.attributes['lightScheduleIdRef']}|#{element.attributes['equipmentScheduleIdRef']}|#{element.attributes['peopleScheduleIdRef']}"
      if ! advanced_inputs[:schedule_sets].has_key?(target_sch_set_key)
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
      if not target_sch_set_key == "||"
        advanced_inputs[:spaces][element.attributes['id']][:sch_set] = target_sch_set_key
      end
      if ! element.attributes['zoneIdRef'].nil?
        advanced_inputs[:spaces][element.attributes['id']][:zone_id_ref] = element.attributes['zoneIdRef']
      end
      if ! element.attributes['conditionType'].nil?
        advanced_inputs[:spaces][element.attributes['id']][:condition_type] = element.attributes['conditionType']
      end
      if ! element.elements['Name'].nil?
        advanced_inputs[:spaces][element.attributes['id']][:name] = element.elements['Name'].text
      end

      # populate hash for space load instances for people, lights and electric equipment. Don't duplicate load definitions if an equivalent one has already been made.
      # gather lights
      if ! element.elements['LightPowerPerArea'].nil?
        # todo - add code for different unit types, for now assuming value is w/ft^2
        light_power_per_area = element.elements['LightPowerPerArea'].text.to_f
        if ! advanced_inputs[:light_defs].has_key?(light_power_per_area)
          advanced_inputs[:light_defs][light_power_per_area] = "adv_import_light_#{advanced_inputs[:light_defs].size}"
        end
        advanced_inputs[:spaces][element.attributes['id']][:light_defs] = light_power_per_area
      end
      # gather electric equipment
      if ! element.elements['EquipPowerPerArea'].nil?
        # todo - add code for different unit types, for now assuming value is w/ft^2
        light_power_per_area = element.elements['EquipPowerPerArea'].text.to_f
        if ! advanced_inputs[:equip_defs].has_key?(light_power_per_area)
          advanced_inputs[:equip_defs][light_power_per_area] = "adv_import_elec_equip_#{advanced_inputs[:equip_defs].size}"
        end
        advanced_inputs[:spaces][element.attributes['id']][:equip_defs] = light_power_per_area
      end
      # gather people
      # unlike lights and equipment, there are multiple people objects in the space to inspect
      space_people_attributes = {}
      element.elements.each('PeopleHeatGain') do |people_heat_gain|
        # todo - add code for different unit types, for now assuming value is w/ft^2
        #unit = people_heat_gain.attributes['unit']
        heat_gain_type = people_heat_gain.attributes['heatGainType']
        space_people_attributes["people_heat_gain_#{heat_gain_type.downcase}"] = people_heat_gain.text.to_f
      end
      if ! element.elements['PeopleNumber'].nil?
        space_people_attributes[:people_number] = element.elements['PeopleNumber'].text.to_f
      end
      if ! advanced_inputs[:people_defs].has_key?(space_people_attributes) && space_people_attributes.size > 0
        advanced_inputs[:people_defs][space_people_attributes] = "adv_import_people_#{advanced_inputs[:people_defs].size}"
      end
      if space_people_attributes.size > 0
        advanced_inputs[:spaces][element.attributes['id']][:people_defs] = space_people_attributes
      end

    end

    puts "**Looping through schedules"
    # note, schedules and schedule sets will be generated as used when looping through spaces
    gbxml_doc.elements.each('gbXML/Schedule') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "Schedule #{element.attributes['id']} does not have a name"
      end
      # add schedules to hash with array of week schedules
      # todo - get sample with multiple WeekScheduleId objects and support that in schedule generation
      sch_week = element.elements['YearSchedule/WeekScheduleId'].attributes['weekScheduleIdRef']
      advanced_inputs[:schedules][element.attributes['id']] = {'name' => name.text, 'sch_week' => sch_week}
    end

    puts "**Looping through week schedules"
    # note, schedules and schedule sets will be generated as used when looping through spaces
    gbxml_doc.elements.each('gbXML/WeekSchedule') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "WeekSchedule #{element.attributes['id']} does not have a name"
      end
      # add schedules to hash with array of week schedules
      day_types = {}
      element.elements.each do |day_type|
        next if !day_type.attributes.has_key?('dayType')
        day_types[day_type.attributes['dayType']] = day_type.attributes['dayScheduleIdRef']
      end
      advanced_inputs[:week_schedules][element.attributes['id']] = day_types
    end

    puts "**Looping through day schedules"
    # note, schedules and schedule sets will be generated as used when looping through spaces
    gbxml_doc.elements.each('gbXML/DaySchedule') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "DaySchedule #{element.attributes['id']} does not have a name"
      end
      # add schedules to hash with array of week schedules
      hourly_values = []
      element.elements.each do |hour|
        hourly_values << hour.text.to_f
      end
      advanced_inputs[:day_schedules][element.attributes['id']] = hourly_values
    end

    puts "**Looping through zones"
    gbxml_doc.elements.each('gbXML/Zone') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "Zone #{element.attributes['id']} does not have a name"
      end
    end

    puts "**Looping through ZoneHVACEquipment"
    gbxml_doc.elements.each('gbXML/ZoneHVACEquipment') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "ZoneHVACEquipment #{element.attributes['id']} does not have a name"
      end
    end

    puts "**Looping through AirSystem"
    gbxml_doc.elements.each('gbXML/AirSystem') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "ZoneHVACEquipment #{element.attributes['id']} does not have a name"
      end
    end

    puts "**Looping through HydronicLoop"
    gbxml_doc.elements.each('gbXML/HydronicLoop') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "ZoneHVACEquipment #{element.attributes['id']} does not have a name"
      end
    end

    # todo - remove temp code to inspect hash
    puts "** inspecting space hash"
    puts advanced_inputs[:spaces]
    puts "** inspecting schedule set hash"
    puts advanced_inputs[:schedule_sets]
    puts "** inspecting schedule hash"
    puts advanced_inputs[:schedules]
    puts "** inspecting week schedule hash"
    puts advanced_inputs[:week_schedules]
    puts "** inspecting day schedule hash"
    puts advanced_inputs[:day_schedules]
    puts "** inspecting lights"
    puts advanced_inputs[:light_defs]
    puts "** inspecting elec equip"
    puts advanced_inputs[:equip_defs]
    puts "** inspecting people"
    puts advanced_inputs[:people_defs]

    # create model objects from hash
    OsLib_AdvImport.add_objects_from_adv_import_hash(runner,model,advanced_inputs)

    # cleanup fenestration that may be too large (need to confirm how doors and glass doors are addressed)
    OsLib_AdvImport.assure_fenestration_inset(runner,model)

    # report final condition of model
    runner.registerFinalCondition("The building finished with #{model.objects.size} model objects.")

    return true
  end
end

# register the measure to be used by the application
AdvancedImportGbxml.new.registerWithApplication
