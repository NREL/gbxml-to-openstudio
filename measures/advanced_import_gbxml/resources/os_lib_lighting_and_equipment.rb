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

require "#{File.dirname(__FILE__)}/os_lib_schedules"

# load OpenStudio measure libraries
module OsLib_LightingAndEquipment
  include OsLib_Schedules

  # return min ans max from array
  def self.getExteriorLightsValue(model)
    facility = model.getFacility
    exterior_lights_power = 0
    exterior_lights = facility.exteriorLights
    exterior_lights.each do |exterior_light|
      exterior_light_multiplier = exterior_light.multiplier
      exterior_light_def = exterior_light.exteriorLightsDefinition
      exterior_light_base_power = exterior_light_def.designLevel
      exterior_lights_power += exterior_light_base_power * exterior_light_multiplier
    end

    result = { 'exterior_lighting_power' => exterior_lights_power, 'exterior_lights' => exterior_lights }
    return result
  end

  # return min ans max from array
  def self.removeAllExteriorLights(model, runner)
    facility = model.getFacility
    lightsRemoved = false
    exterior_lights = facility.exteriorLights
    exterior_lights.each do |exterior_light|
      runner.registerInfo("Removed exterior light named #{exterior_light.name}.")
      exterior_light.remove
      lightsRemoved = true
    end

    result = lightsRemoved
    return result
  end

  # return min ans max from array
  def self.addExteriorLights(model, runner, options = {})
    # set defaults to use if user inputs not passed in
    defaults = {
      'name' => 'Exterior Light',
      'power' => 0,
      'subCategory' => 'Exterior Lighting',
      'controlOption' => 'AstronomicalClock',
      'setbackStartTime' => 0,
      'setbackEndTime' => 0,
      'setbackFraction' => 0.25
    }

    # merge user inputs with defaults
    options = defaults.merge(options)

    ext_lights_def = OpenStudio::Model::ExteriorLightsDefinition.new(model)
    ext_lights_def.setName("#{options['name']} Definition")
    runner.registerInfo("Setting #{ext_lights_def.name} to a design power of #{options['power']} Watts")
    ext_lights_def.setDesignLevel(options['power'])

    # creating schedule type limits for the exterior lights schedule
    ext_lights_sch_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
    ext_lights_sch_type_limits.setName("#{options['name']} Fractional")
    ext_lights_sch_type_limits.setLowerLimitValue(0)
    ext_lights_sch_type_limits.setUpperLimitValue(1)
    ext_lights_sch_type_limits.setNumericType('Continuous')

    # prepare values for profile
    if options['setbackStartTime'] == 24
      profile = { options['setbackEndTime'] => options['setbackFraction'], 24.0 => 1.0 }
    elsif options['setbackStartTime'] == 0
      profile = { options['setbackEndTime'] => options['setbackFraction'], 24.0 => 1.0 }
    elsif options['setbackStartTime'] > options['setbackEndTime']
      profile = { options['setbackEndTime'] => options['setbackFraction'], options['setbackStartTime'] => 1.0, 24.0 => options['setbackFraction'] }
    else
      profile = { options['setbackStartTime'] => 1.0, options['setbackEndTime'] => options['setbackFraction'] }
    end

    # inputs
    createSimpleSchedule_inputs = {
      'name' => options['name'],
      'winterTimeValuePairs' => profile,
      'summerTimeValuePairs' => profile,
      'defaultTimeValuePairs' => profile
    }

    # create a ruleset schedule with a basic profile
    ext_lights_sch = OsLib_Schedules.createSimpleSchedule(model, createSimpleSchedule_inputs)

    # creating exterior lights object
    ext_lights = OpenStudio::Model::ExteriorLights.new(ext_lights_def, ext_lights_sch)
    ext_lights.setName("#{options['power']} w Exterior Light")
    ext_lights.setControlOption(options['controlOption'])
    ext_lights.setEndUseSubcategory(options['subCategory'])

    result = ext_lights
    return result
  end

  # add daylight sensor
  def self.addDaylightSensor(model, options = {})
    # set defaults to use if user inputs not passed in
    defaults = {
      'name' => nil,
      'space' => nil,
      'position' => nil,
      'phiRotationAroundZAxis' => nil,
      'illuminanceSetpoint' => nil,
      'lightingControlType' => '1', # 1 = Continuous
      'minInputPowerFractionContinuous' => nil,
      'minOutputPowerFractionContinuous' => nil,
      'numberOfSteppedControlSteps' => nil
    }

    # merge user inputs with defaults
    options = defaults.merge(options)

    pri_light_sensor = OpenStudio::Model::DaylightingControl.new(model)
    if !options['name'].nil? then pri_light_sensor.setName(options['name']) end
    if !options['space'].nil? then pri_light_sensor.setSpace(options['space']) end
    if !options['position'].nil? then pri_light_sensor.setPosition(options['position']) end
    if !options['phiRotationAroundZAxis'].nil? then pri_light_sensor.setPhiRotationAroundZAxis(options['phiRotationAroundZAxis']) end
    if !options['illuminanceSetpoint'].nil? then  pri_light_sensor.setIlluminanceSetpoint(options['illuminanceSetpoint']) end
    if !options['lightingControlType'].nil? then  pri_light_sensor.setLightingControlType(options['lightingControlType']) end

    result = pri_light_sensor
    return result
  end

  # make hash of hard assigned schedules with lighting levels
  def self.createHashOfInternalLoadWithHardAssignedSchedules(internalLoadArray)
    hardAssignedScheduleHash = {}
    internalLoadArray.each do |load|
      if !load.isScheduleDefaulted
        # add to schedule hash
        if !load.schedule.empty?
          if !(hardAssignedScheduleHash[load.schedule.get])
            hardAssignedScheduleHash[load.schedule.get] = 1
          else
            hardAssignedScheduleHash[load.schedule.get] += 1 # this is to catch multiple objects instances using the same hard assigned schedule
          end
        end
      end
    end

    result = hardAssignedScheduleHash
    return result
  end

  # get value per area for electric equipment loads in space array.
  def self.getEpdForSpaceArray(spaceArray)
    floorArea = 0
    electricEquipmentPower = 0

    spaceArray.each do |space|
      floorArea += space.floorArea * space.multiplier
      electricEquipmentPower += space.electricEquipmentPower * space.multiplier
    end

    epd = electricEquipmentPower / floorArea

    result = epd
    return result
  end

  # get value per area for electric equipment loads in space array.
  def self.getLpdForSpaceArray(spaceArray)
    floorArea = 0
    lightingPower = 0

    spaceArray.each do |space|
      floorArea += space.floorArea * space.multiplier
      lightingPower += space.lightingPower * space.multiplier
    end

    lpd = lightingPower / floorArea

    result = lpd
    return result
  end
end
