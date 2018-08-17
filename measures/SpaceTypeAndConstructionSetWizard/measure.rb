# *******************************************************************************
# OpenStudio(R), Copyright (c) 2008-2018, Alliance for Sustainable Energy, LLC.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# (4) Other than as required in clauses (1) and (2), distributions in any form
# of modifications or other derivative works may not use the "OpenStudio"
# trademark, "OS", "os", or any other confusingly similar designation without
# specific prior written permission from Alliance for Sustainable Energy, LLC.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

# see the URL below for information on how to write OpenStudio measures
# http://openstudio.nrel.gov/openstudio-measure-writing-guide

# see the URL below for information on using life cycle cost objects in OpenStudio
# http://openstudio.nrel.gov/openstudio-life-cycle-examples

# see the URL below for access to C++ documentation on model objects (click on "model" in the main window to view model objects)
# http://openstudio.nrel.gov/sites/openstudio.nrel.gov/files/nv_data/cpp_documentation_it/model/html/namespaces.html

# start the measure
class SpaceTypeAndConstructionSetWizard < OpenStudio::Measure::ModelMeasure
  require 'openstudio-standards'

  # require all .rb files in resources folder
  Dir[File.dirname(__FILE__) + '/resources/*.rb'].each { |file| require file }

  # resource files used by measure
  include OsLib_HelperMethods
  include OsLib_ModelGeneration

  # define the name that a user will see, this method may be deprecated as
  # the display name in PAT comes from the name field in measure.xml
  def name
    'Space Type and Construction Set Wizard'
  end

  # human readable description
  def description
    'Create space types and or construction sets for the requested building type, climate zone, and target.'
  end

  # human readable description of modeling approach
  def modeler_description
    'The data for this measure comes from the openstudio-standards Ruby Gem. They are no longer created from the same JSON file that was used to make the OpenStudio templates. Optionally this will also set the building default space type and construction set.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Make an argument for the building type
    building_type = OpenStudio::Measure::OSArgument.makeChoiceArgument('building_type', get_building_types, true)
    building_type.setDisplayName('Building Type.')
    building_type.setDefaultValue('SmallOffice')
    args << building_type

    # Make an argument for the template
    template_chs = OpenStudio::StringVector.new
    template_chs << 'DOE Ref Pre-1980'
    template_chs << 'DOE Ref 1980-2004'
    template_chs << '90.1-2004'
    template_chs << '90.1-2007'
    # template_chs << '189.1-2009' # if turn this on need to update space_type_array for stripmall
    template_chs << '90.1-2010'
    template_chs << '90.1-2013'
    template = OpenStudio::Measure::OSArgument.makeChoiceArgument('template', template_chs, true)
    template.setDisplayName('Template.')
    template.setDefaultValue('90.1-2013')
    args << template

    # Make an argument for the climate zone
    climate_zone_chs = OpenStudio::StringVector.new
    climate_zone_chs << 'ASHRAE 169-2006-1A'
    climate_zone_chs << 'ASHRAE 169-2006-1B' # TODO: - test
    climate_zone_chs << 'ASHRAE 169-2006-2A'
    climate_zone_chs << 'ASHRAE 169-2006-2B'
    climate_zone_chs << 'ASHRAE 169-2006-3A'
    climate_zone_chs << 'ASHRAE 169-2006-3B'
    climate_zone_chs << 'ASHRAE 169-2006-3C'
    climate_zone_chs << 'ASHRAE 169-2006-4A'
    climate_zone_chs << 'ASHRAE 169-2006-4B'
    climate_zone_chs << 'ASHRAE 169-2006-4C'
    climate_zone_chs << 'ASHRAE 169-2006-5A'
    climate_zone_chs << 'ASHRAE 169-2006-5B'
    climate_zone_chs << 'ASHRAE 169-2006-5C' # TODO: - test
    climate_zone_chs << 'ASHRAE 169-2006-6A'
    climate_zone_chs << 'ASHRAE 169-2006-6B'
    climate_zone_chs << 'ASHRAE 169-2006-7A'
    climate_zone_chs << 'ASHRAE 169-2006-8A'
    climate_zone = OpenStudio::Measure::OSArgument.makeChoiceArgument('climate_zone', climate_zone_chs, true)
    climate_zone.setDisplayName('Climate Zone.')
    climate_zone.setDefaultValue('ASHRAE 169-2006-2A')
    args << climate_zone

    # make an argument to add new space types
    create_space_types = OpenStudio::Measure::OSArgument.makeBoolArgument('create_space_types', true)
    create_space_types.setDisplayName('Create Space Types?')
    create_space_types.setDefaultValue(true)
    args << create_space_types

    # make an argument to add new construction set
    create_construction_set = OpenStudio::Measure::OSArgument.makeBoolArgument('create_construction_set', true)
    create_construction_set.setDisplayName('Create Construction Set?')
    create_construction_set.setDefaultValue(true)
    args << create_construction_set

    # make an argument to determine if building defaults should be set
    set_building_defaults = OpenStudio::Measure::OSArgument.makeBoolArgument('set_building_defaults', true)
    set_building_defaults.setDisplayName('Set Building Defaults Using New Objects?')
    set_building_defaults.setDefaultValue(true)
    args << set_building_defaults

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
    building_type = runner.getStringArgumentValue('building_type', user_arguments)
    template = runner.getStringArgumentValue('template', user_arguments)
    climate_zone = runner.getStringArgumentValue('climate_zone', user_arguments)
    create_space_types = runner.getBoolArgumentValue('create_space_types', user_arguments)
    create_construction_set = runner.getBoolArgumentValue('create_construction_set', user_arguments)
    set_building_defaults = runner.getBoolArgumentValue('set_building_defaults', user_arguments)

    # reporting initial condition of model
    starting_spaceTypes = model.getSpaceTypes
    starting_constructionSets = model.getDefaultConstructionSets
    runner.registerInitialCondition("The building started with #{starting_spaceTypes.size} space types and #{starting_constructionSets.size} construction sets.")

    # lookup space types for specified building type (false indicates not to use whole building type only)
    space_type_hash = get_space_types_from_building_type(building_type, template, false)
    if space_type_hash == false
      runner.registerError("#{building_type} is an unexpected building type.")
      return false
    end

    # create space_type_map from array
    space_type_map = {}
    default_space_type_name = nil
    space_type_hash.each do |space_type_name, hash|
      next if hash[:space_type_gen] == false # space types like undeveloped and basement are skipped.
      space_type_map[space_type_name] = [] # no spaces to pass in
      if hash[:default]
        default_space_type_name = space_type_name
      end
    end

    # Make the standard applier
    standard = Standard.build(template)

    # mapping building_type name is needed for a few methods
    lookup_building_type = standard.model_get_lookup_name(building_type)

    # remap small medium and large office to office
    if building_type.include?("Office") then building_type = "Office" end

    # create_space_types
    if create_space_types

      # array of starting space types
      space_types_starting = model.getSpaceTypes

      # get array of new space types
      space_types_new = []

      # create stub space types
      space_type_hash.each do |space_type_name, hash|
        next if hash[:space_type_gen] == false # space types like undeveloped and basement are skipped.

        # create space type
        space_type = OpenStudio::Model::SpaceType.new(model)
        space_type.setStandardsBuildingType(building_type)
        space_type.setStandardsSpaceType(space_type_name)
        space_type.setName("#{building_type} #{space_type_name}")

        # add to array of new space types
        space_types_new << space_type

        # add internal loads (the nil check isn't ncessary, but I will keep it in as a warning instad of an error)
        test = standard.space_type_apply_internal_loads(space_type, true, true, true, true, true, true)
        if test.nil?
          runner.registerWarning("Could not add loads for #{space_type.name}. Not expected for #{template} #{lookup_building_type}")
        end

        # the last bool test it to make thermostat schedules. They are added to the model but not assigned
        standard.space_type_apply_internal_load_schedules(space_type, true, true, true, true, true, true, true)

        # assign colors
        standard.space_type_apply_rendering_color(space_type)

        # exend space type name to include the template. Consider this as well for load defs
        space_type.setName("#{space_type.name} - #{template}")
        runner.registerInfo("Added space type named #{space_type.name}")
      end

    end

    # add construction sets
    bldg_def_const_set = nil
    if create_construction_set

      # Make the default construction set for the building
      is_residential = 'No' # default is nonresidential for building level
      bldg_def_const_set = standard.model_add_construction_set(model, climate_zone, lookup_building_type, nil, is_residential)
      if bldg_def_const_set.is_initialized
        bldg_def_const_set = bldg_def_const_set.get
        sub_surface_constructions = bldg_def_const_set.defaultExteriorSubSurfaceConstructions.get
        window = sub_surface_constructions.fixedWindowConstruction.get
        sub_surface_constructions.setGlassDoorConstruction(window)
        runner.registerInfo("Added default construction set named #{bldg_def_const_set.name}")
      else
        runner.registerError('Could not create default construction set for the building.')
        return false
      end

      # make residential construction set as unused resource
      if ['SmallHotel', 'LargeHotel', 'MidriseApartment', 'HighriseApartment'].include?(building_type)
        res_const_set = standard.model_add_construction_set(model, climate_zone, lookup_building_type, nil, 'Yes')
        if res_const_set.is_initialized
          res_const_set = res_const_set.get
          res_const_set.setName("#{bldg_def_const_set.name} - Residential ")
          runner.registerInfo("Added residential construction set named #{res_const_set.name}")
        else
          runner.registerError('Could not create residential construction set for the building.')
          return false
        end
      end

    end

    # set_building_defaults
    if set_building_defaults

      # identify default space type
      space_type_standards_info_hash = OsLib_HelperMethods.getSpaceTypeStandardsInformation(space_types_new)
      default_space_type = nil
      space_type_standards_info_hash.each do |space_type, standards_array|
        standards_space_type = standards_array[1]
        if default_space_type_name == standards_space_type
          default_space_type = space_type
        end
      end

      # set default space type
      building = model.getBuilding
      building.setSpaceType(default_space_type)
      runner.registerInfo("Setting default Space Type for building to #{building.spaceType.get.name}")

      # default construction
      building.setDefaultConstructionSet(bldg_def_const_set)
      runner.registerInfo("Setting default Construction Set for building to #{building.defaultConstructionSet.get.name}")

      # set climate zone
      os_climate_zone = climate_zone.gsub('ASHRAE 169-2006-', '')
      # trim off letter from climate zone 7 or 8
      if (os_climate_zone[0] == '7') || (os_climate_zone[0] == '8')
        os_climate_zone = os_climate_zone[0]
      end
      climate_zone = model.getClimateZones.setClimateZone('ASHRAE', os_climate_zone)
      runner.registerInfo("Setting #{climate_zone.institution} Climate Zone to #{climate_zone.value}")

      # set building type
      # use lookup_building_type so spaces like MediumOffice will map to Office (Supports baseline automation)
      building.setStandardsBuildingType(lookup_building_type)
      runner.registerInfo("Setting Standards Building Type to #{building.standardsBuildingType}")

      # rename building if it is named "Building 1"
      if model.getBuilding.name.to_s == 'Building 1'
        model.getBuilding.setName("#{building_type} #{template} #{os_climate_zone}")
        runner.registerInfo("Renaming building to #{model.getBuilding.name}")
      end

    end

    # reporting final condition of model
    finishing_spaceTypes = model.getSpaceTypes
    finishing_constructionSets = model.getDefaultConstructionSets
    runner.registerFinalCondition("The building finished with #{finishing_spaceTypes.size} space types and #{finishing_constructionSets.size} construction sets.")

    return true
  end
end

# this allows the measure to be use by the application
SpaceTypeAndConstructionSetWizard.new.registerWithApplication
