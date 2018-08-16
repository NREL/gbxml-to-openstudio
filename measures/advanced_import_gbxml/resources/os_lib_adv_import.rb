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
module OsLib_AdvImport

  # primary method that calls other methods to add objects
  def self.add_objects_from_adv_import_hash(runner,model,advanced_inputs)

    # make schedules
    schedules = import_schs(runner,model,advanced_inputs[:schedules])

    # make schedules sets
    schedule_sets = import_sch_set(runner,model,advanced_inputs[:schedule_sets],schedules)

    # todo - make load defs

    # todo - make space load instances and assign schedule sets to spaces
    schedule_sets = assign_space_attributes(runner,model,advanced_inputs[:spaces],schedule_sets)

    # QAQC checks and fixes
    # todo - if a space has a schedule for number of people make add default people instance and acitivity schedule if it doesn't already have one

    return true
  end

  # assign newly made space objects to existing spaces
  def self.assign_space_attributes(runner,model,spaces,schedule_sets)

    # loop through spaces and assign attributes
    # note that spaces in model may use name element if it exist instead of id attribute
    modified_spaces = {}
    spaces.each do |id,space_data|

      modified = false

      # find model space
      if space_data.has_key?(:name) &&  model.getSpaceByName(space_data[:name]).is_initialized
        space = model.getSpaceByName(space_data[:name]).get
      elsif  model.getSpaceByName(id).is_initialized
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

      # todo - create lighting load instances

      # todo - create electric equipment load instances

      # todo - create people load instances

      # if modified add to modified_spaces hash
      if modified
        modified_spaces[id] = space
      end

    end
    runner.registerInfo("Assigned new data to  #{modified_spaces.size} existing spaces in the model.")

    return modified_spaces
  end

  # create ruleset schedule from inputs
  def self.import_schs(runner,model,schedules)

    # loop through and add schedules
    new_schedules = {}
    schedules.each do |id,schedule_data|
      sch_ruleset = OpenStudio::Model::ScheduleRuleset.new(model)
      sch_ruleset.setName(id)
      new_schedules[id] = sch_ruleset
      # todo - populate schedule using schedule_data
    end
    runner.registerInfo("Created #{new_schedules.size} new Schedule Ruleset objets.")

    return new_schedules
  end

  # create schedule set from inputs
  def self.import_sch_set(runner,model,schedule_sets,schedules)

    # loop through and add schedule sets
    new_schedule_sets = {}
    schedule_sets.each do |id,schedule_set_data|
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
    runner.registerInfo("Created #{new_schedule_sets.size} new Default Schedule Set objets.")

    return new_schedule_sets
  end

  # run wwr fix where greater than 99%
  def self.assure_fenestration_inset(runner,model)

    # loop through surfaces
    modified_surfaces = []
    model.getSurfaces.each do |surface|
      wwr = surface.windowToWallRatio
      if wwr > 0.99
        sub_surface = surface.subSurfaces[0] # todo - assumes only one which may not be correct
        centroid = OpenStudio::getCentroid(sub_surface.vertices).get
        new_vertices = OpenStudio::moveVerticesTowardsPoint(sub_surface.vertices, centroid, 0.01)
        sub_surface.setVertices(new_vertices)
        #runner.registerInfo("WWR changed from #{wwr} to #{surface.windowToWallRatio}.")
        modified_surfaces << surface
      end
    end

    # additional logic to get various door types
    model.getSubSurfaces.each do |sub_surface|
      if ["GlassDoor","Door","OverheadDoor"].include?(sub_surface.subSurfaceType)
        centroid = OpenStudio::getCentroid(sub_surface.vertices).get
        new_vertices = OpenStudio::moveVerticesTowardsPoint(sub_surface.vertices, centroid, 0.01)
        sub_surface.setVertices(new_vertices)
        modified_surfaces << sub_surface.surface.get # todo - have not checked if it is orphan
      end
    end

    return modified_surfaces
  end

end
