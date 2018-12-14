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

# while methods initially setup for import from gbXML it can be used with import from any file such as csv, json, idf, etc
# regardless of import format data is passed into these methods as hashes.
require 'bigdecimal/newton'

module OsLib_AdvImport

  # primary method that calls other methods to add objects
  def self.add_objects_from_adv_import_hash(runner, model, advanced_inputs)

    # make schedules
    schedules = import_schs(runner, model, advanced_inputs[:schedules], advanced_inputs[:week_schedules], advanced_inputs[:day_schedules])

    # make schedules sets
    schedule_sets = import_sch_set(runner, model, advanced_inputs[:schedule_sets], schedules)

    # make load defs
    lights = import_lights(runner, model, advanced_inputs[:light_defs])
    elec_equipment = import_elec_equipment(runner, model, advanced_inputs[:equip_defs])
    people = import_people(runner, model, advanced_inputs[:people_defs])

    # make space load instances and assign schedule sets to spaces
    modified_spaces = assign_space_attributes(runner, model, advanced_inputs[:spaces], schedule_sets, lights, elec_equipment, people)

    return true
  end

  # assign newly made space objects to existing spaces
  def self.assign_space_attributes(runner, model, spaces, schedule_sets, lights, elec_equipment, people)

    # loop through spaces and assign attributes
    # ventilation and infiltration do not have separate load definitions, and are assigned directly to the space
    # note that spaces in model may use name element if it exist instead of id attribute
    modified_spaces = {}
    spaces.each do |id, space_data|

      modified = false

      # find model space
      if space_data.has_key?(:name) && model.getSpaceByName(space_data[:name]).is_initialized
        space = model.getSpaceByName(space_data[:name]).get
      elsif model.getSpaceByName(id).is_initialized
        space = model.getSpaceByName(id).get
      else
        runner.registerWarning("Did not find space in model assciated with #{id}. Not connecting objects realted to this space.")
        next
      end

      # assign schedule_sets
      if space_data.has_key?(:sch_set)
        sch_set = schedule_sets[space_data[:sch_set]]
        space.setDefaultScheduleSet(sch_set)
        modified = true
      end

      # create lighting load instances
      if space_data.has_key?(:light_defs)
        load_def = lights[space_data[:light_defs]]
        load_inst = OpenStudio::Model::Lights.new(load_def)
        load_inst.setName("#{space.name.to_s}_lights")
        load_inst.setSpace(space)
        modified = true
      end

      # create electric equipment load instances
      if space_data.has_key?(:equip_defs)
        load_def = elec_equipment[space_data[:equip_defs]]
        load_inst = OpenStudio::Model::ElectricEquipment.new(load_def)
        load_inst.setName("#{space.name.to_s}_elec_equip")
        load_inst.setSpace(space)
        modified = true
      end

      # create people load instances
      if space_data.has_key?(:people_defs)
        load_def = people[space_data[:people_defs]]
        load_inst = OpenStudio::Model::People.new(load_def)
        load_inst.setName("#{space.name.to_s}_people")
        load_inst.setSpace(space)
        modified = true

        # create activity schedule if not already made and assign
        # todo - this would be better setup as part of schedule set
        # todo - inputs of Btu/h in sample of 40 seems 10x lower than expected to be 120W
        # todo - take latent and sensible ratio to update peopleDefinition object
        if space_data[:people_defs].has_key?('people_heat_gain_total')
          activity_btu_h = space_data[:people_defs]['people_heat_gain_total']
          activity_w = OpenStudio.convert(activity_btu_h, 'Btu/h', 'W').get
          # assign or create schedule
          if model.getScheduleRulesetByName("activity_#{activity_w}").is_initialized
            sch_ruleset = model.getScheduleRulesetByName("activity_#{activity_w}").get
          else
            options = {'name' => "activity_#{activity_w}", 'default_day' => ["activity_#{activity_w}_default", [24.0, activity_w]]}
            sch_ruleset = OsLib_Schedules.createComplexSchedule(model, options)
          end
        else
          # create default activity level if one doesn't exist
          default_activity = 120.0
          options = {'name' => "activity_#{activity_w}", 'default_day' => ["activity_#{activity_w}_default", [24.0, default_activity]]}
          sch_ruleset = OsLib_Schedules.createComplexSchedule(model, options)
          runner.registerWarning("Did not find data for acitivty schedule, adding default of #{default_activity} W.")
        end
        load_inst.setActivityLevelSchedule(sch_ruleset)
      end

      # create infiltration load instances
      if space_data.has_key?(:infiltration_def)
        load_inst = OpenStudio::Model::SpaceInfiltrationDesignFlowRate.new(model)
        # include guard clause for valid infiltration input
        value_m3_s = OpenStudio.convert(space_data[:infiltration_def][:infiltration_flow_per_space], 'cfm', 'm^3/s').get
        load_inst.setDesignFlowRate(value_m3_s)
        value_m_s = OpenStudio.convert(space_data[:infiltration_def][:infiltration_flow_per_space_area], 'cfm/ft^2', 'm/s').get
        load_inst.setFlowperSpaceFloorArea(value_m_s)
        value_m_s = OpenStudio.convert(space_data[:infiltration_def][:infiltration_flow_per_exterior_surface_area], 'cfm/ft^2', 'm/s').get
        load_inst.setFlowperExteriorSurfaceArea(value_m_s)
        value_m_s = OpenStudio.convert(space_data[:infiltration_def][:infiltration_flow_per_exterior_wall_area], 'cfm/ft^2', 'm/s').get
        load_inst.setFlowperExteriorWallArea(value_m_s)
        load_inst.setAirChangesperHour(space_data[:infiltration_def][:infiltration_flow_air_changes_per_hour])
        load_inst.setName("#{space.name.to_s}_infiltration")
        load_inst.setSpace(space)
        modified = true
      end

      # create ventilation instances
      if space_data.has_key?(:ventilation_def)
        vent_inst = OpenStudio::Model::DesignSpecificationOutdoorAir.new(model)
        # include guard clause for valid ventilation input
        value_m3_s = OpenStudio.convert(space_data[:ventilation_def][:ventilation_flow_per_person], 'cfm', 'm^3/s').get
        vent_inst.setOutdoorAirFlowperPerson(value_m3_s)
        value_m_s = OpenStudio.convert(space_data[:ventilation_def][:ventilation_flow_per_area], 'cfm/ft^2', 'm/s').get
        vent_inst.setOutdoorAirFlowperFloorArea(value_m_s)
        value_m3_s = OpenStudio.convert(space_data[:ventilation_def][:ventilation_flow_per_space], 'cfm', 'm^3/s').get
        vent_inst.setOutdoorAirFlowRate(value_m3_s)
        vent_inst.setOutdoorAirFlowAirChangesperHour(space_data[:ventilation_def][:ventilation_flow_air_changes_per_hour])
        vent_inst.setName("#{space.name.to_s}_ventilation")
        vent_inst.setSpace(space)
        modified = true
      end

      # if modified add to modified_spaces hash
      if modified
        modified_spaces[id] = space
      end

    end
    runner.registerInfo("Assigned new data to  #{modified_spaces.size} existing spaces in the model.")

    return modified_spaces
  end

  # create ruleset schedule from inputs
  def self.import_schs(runner, model, schedules, week_schedules, day_schedules)

    # loop through and add schedules
    new_schedules = {}

    # process schedule data
    schedules.each do |id, schedule_data|

      # get schedule name
      if schedule_data['name'].nil?
        ruleset_name = id
      else
        ruleset_name = schedule_data['name']
      end
      date_range = '1/1-12/31' # todo - in future pull form gbxml
      winter_design_day = nil
      summer_design_day = nil
      default_day = nil
      rules = []

      # get WeekSchedule
      week_schs = week_schedules[schedule_data['sch_week']]

      # loop through dayTypes
      week_schs.each do |day_type,day_obj|

        # get associated dayType items
        time_value_array_raw = []
        day_schedules[day_obj].each_with_index do  |value,i|
          time_value_array_raw << [i+1,value]
        end

        # clean up excess values
        time_value_array = []
        last_val = nil
        time_value_array_raw.reverse.each do |time_val|
          if last_val.nil?
            time_value_array << time_val
          elsif last_val != time_val[1]
            time_value_array << time_val
          end
          last_val = time_val[1]
        end
        time_value_array = time_value_array.reverse

        # create default profile, rule, or design day #
        if day_type == "HeatingDesignDay"
          winter_design_day = time_value_array
        elsif day_type == "CoolingDesignDay"
          summer_design_day = time_value_array
        elsif day_type == "Holiday"
          # do nothing, not currently supporting holidays
        elsif default_day.nil?
          default_day = time_value_array.insert(0,day_type) #day_type is name of default day profile object
        elsif day_type == "All"
          prefix_array = [day_type,date_range,'Mon/Tue/Wed/Thu/Fri/Sat/Sun']
          rules << prefix_array + time_value_array
        elsif day_type == "Weekday"
          prefix_array = [day_type,date_range,'Mon/Tue/Wed/Thu/Fri']
          rules << prefix_array + time_value_array
        elsif day_type == "Sat"
          prefix_array = [day_type,date_range,'Sat']
          rules << prefix_array + time_value_array
        elsif day_type == "Sun"
          prefix_array = [day_type,date_range,'Sun']
          rules << prefix_array + time_value_array
        elsif day_type == "Mon"
          prefix_array = [day_type,date_range,'Mon']
          rules << prefix_array + time_value_array
        elsif day_type == "Tue"
          prefix_array = [day_type,date_range,'Tue']
          rules << prefix_array + time_value_array
        elsif day_type == "Wed"
          prefix_array = [day_type,date_range,'Wed']
          rules << prefix_array + time_value_array
        elsif day_type == "Thu" #todo - confirm weekday abbreviations
          prefix_array = [day_type,date_range,'Thu']
          rules << prefix_array + time_value_array
        elsif day_type == "Fri"
          prefix_array = [day_type,date_range,'Fri']
          rules << prefix_array + time_value_array
        end
      end

      # populate schedule using schedule_data to update default profile and add rules to complex schedule
      options = { 'name' => ruleset_name,
                  'winter_design_day' => winter_design_day,
                  'summer_design_day' => summer_design_day,
                  'default_day' => default_day,
                  'rules' => rules }

      sch_ruleset = OsLib_Schedules.createComplexSchedule(model, options)
      new_schedules[id] = sch_ruleset
    end
    runner.registerInfo("Created #{new_schedules.size} new ScheduleRuleset objects (not including activity schedules).")

    return new_schedules
  end

  # create schedule set from inputs
  def self.import_sch_set(runner, model, schedule_sets, schedules)

    # loop through and add schedule sets
    new_schedule_sets = {}
    schedule_sets.each do |id, schedule_set_data|
      default_sch_set = OpenStudio::Model::DefaultScheduleSet.new(model)
      default_sch_set.setName(id)
      new_schedule_sets[id] = default_sch_set
      # assign them to schedule set
      if schedule_set_data.has_key?(:light_schedule_id_ref)
        target_sch = schedules[schedule_set_data[:light_schedule_id_ref]]
        default_sch_set.setLightingSchedule(target_sch)
      end
      if schedule_set_data.has_key?(:equipment_schedule_id_ref)
        target_sch = schedules[schedule_set_data[:equipment_schedule_id_ref]]
        default_sch_set.setElectricEquipmentSchedule(target_sch)
      end
      if schedule_set_data.has_key?(:people_schedule_id_ref)
        target_sch = schedules[schedule_set_data[:people_schedule_id_ref]]
        default_sch_set.setNumberofPeopleSchedule(target_sch)
      end
    end
    runner.registerInfo("Created #{new_schedule_sets.size} new DefaultScheduleSet objects.")

    return new_schedule_sets
  end

  # create lights from inputs
  def self.import_lights(runner, model, load_data)
    new_defs = {}
    load_data.each do |data, id|
      new_def = OpenStudio::Model::LightsDefinition.new(model)
      new_def.setName(id)
      value_w_ft2 = OpenStudio.convert(data, 'W/ft^2', 'W/m^2').get
      new_def.setWattsperSpaceFloorArea(value_w_ft2)
      new_defs[data] = new_def
    end
    runner.registerInfo("Created #{new_defs.size} new LightsDefinition objects.")
    return new_defs
  end

  # create electric equipment from inputs
  def self.import_elec_equipment(runner, model, load_data)
    new_defs = {}
    load_data.each do |data, id|
      new_def = OpenStudio::Model::ElectricEquipmentDefinition.new(model)
      new_def.setName(id)
      value_w_ft2 = OpenStudio.convert(data, 'W/ft^2', 'W/m^2').get
      new_def.setWattsperSpaceFloorArea(value_w_ft2)
      new_defs[data] = new_def
    end
    runner.registerInfo("Created #{new_defs.size} new ElectricEquipmentDefinition objects.")
    return new_defs
  end

  # create people from inputs
  def self.import_people(runner, model, load_data)
    new_defs = {}
    load_data.each do |data, id|
      new_def = OpenStudio::Model::PeopleDefinition.new(model)
      new_def.setName(id)
      if data.has_key?(:people_number)
        new_def.setNumberofPeople(data[:people_number])
      else
        # if number of people doesn't exist, but schedules hash data exists for people, create default value
        default_ft2_per_person = 200.0
        default_m2_per_person = OpenStudio.convert(default_ft2_per_person, 'ft^2', 'm^2').get
        new_def.setSpaceFloorAreaperPerson(default_m2_per_person)
        runner.registerWarning("Found heat gain for people but not number of people, adding default value of #{default_ft2_per_person} ft^2 per person.")
      end
      new_defs[data] = new_def
    end
    runner.registerInfo("Created #{new_defs.size} new PeopleDefinition objects.")
    return new_defs
  end

  # run wwr fix where greater than 99%
  def self.assure_fenestration_inset(runner, model)

    # Reduce all subsurfaces for
    model.getSurfaces.each do |surface|
      surface.subSurfaces.each do |sub_surface|
        new_area = sub_surface.grossArea * 0.98
        new_vertices = adjust_vertices_to_area(sub_surface.vertices, new_area, 0.00000001)
        sub_surface.setVertices(new_vertices)
      end

      if surface.windowToWallRatio > 0.99
        surface.subSurfaces.each do |sub_surface|
          sub_surface.remove
        end
      end
    end
  end

  def self.adjust_vertices_to_area(vertices, desired_area, eps = 0.1)
    ar = AreaReducer.new(vertices, desired_area, eps)

    n = Newton::nlsolve(ar, [0])
    return ar.new_vertices
  end
end

module Newton
  def self.jacobian(f, fx, x)
    Jacobian.jacobian(f, fx, x)
  end

  def self.ludecomp(a, n, zero = 0, one = 1)
    LUSolve.ludecomp(a, n, zero, one)
  end

  def self.lusolve(a, b, ps, zero = 0.0)
    LUSolve.lusolve(a, b, ps, zero)
  end
end
# class that does the iteration
class AreaReducer
  attr_reader :zero, :one, :two, :ten, :eps

  def initialize(vertices, desired_area, eps = 0.1)
    @vertices = vertices
    @centroid = OpenStudio::getCentroid(vertices)
    fail "Cannot compute centroid for '#{vertices}'" if @centroid.empty?
    @centroid = @centroid.get
    @desired_area = desired_area
    @new_vertices = vertices

    @zero = BigDecimal::new("0.0")
    @one = BigDecimal::new("1.0")
    @two = BigDecimal::new("2.0")
    @ten = BigDecimal::new("10.0")
    @eps = eps #BigDecimal::new(eps)
  end

  def fancy_new_method(perimeter_depth)
    result = []

    t_inv = OpenStudio::Transformation.alignFace(@vertices)
    t = t_inv.inverse

    vertices = t * @vertices
    new_vertices = OpenStudio::Point3dVector.new
    n = vertices.size
    (0...n).each do |i|
      vertex_1 = nil
      vertex_2 = nil
      vertex_3 = nil
      if i == 0
        vertex_1 = vertices[n - 1]
        vertex_2 = vertices[i]
        vertex_3 = vertices[i + 1]
      elsif i == (n - 1)
        vertex_1 = vertices[i - 1]
        vertex_2 = vertices[i]
        vertex_3 = vertices[0]
      else
        vertex_1 = vertices[i - 1]
        vertex_2 = vertices[i]
        vertex_3 = vertices[i + 1]
      end

      vector_1 = (vertex_2 - vertex_1)
      vector_2 = (vertex_3 - vertex_2)

      angle_1 = Math.atan2(vector_1.y, vector_1.x) + Math::PI / 2.0
      angle_2 = Math.atan2(vector_2.y, vector_2.x) + Math::PI / 2.0

      vector = OpenStudio::Vector3d.new(Math.cos(angle_1) + Math.cos(angle_2), Math.sin(angle_1) + Math.sin(angle_2), 0)
      vector.setLength(perimeter_depth)

      new_point = vertices[i] + vector
      new_vertices << new_point
    end

    return t_inv * new_vertices
  end


  # compute value
  def values(x)

    #@new_vertices = OpenStudio::moveVerticesTowardsPoint(@vertices, @centroid, x[0].to_f)
    @new_vertices = fancy_new_method(x[0].to_f)

    new_area = OpenStudio::getArea(@new_vertices)
    fail "Cannot compute area for '#{@new_vertices}'" if new_area.empty?
    new_area = new_area.get

    # puts "x = #{x[0].to_f}, new_area = #{new_area}"

    return [new_area - @desired_area]
  end

  def new_vertices
    @new_vertices
  end
end

