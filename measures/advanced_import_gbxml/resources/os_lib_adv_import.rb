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
require 'openstudio-standards'

module OsLib_AdvImport

  def self.get_occ_schedules_and_occupancy(model)

    # { {ScheduleRuleset : number of people} : [ThermalZone1, ...] }
    people_schedule_thermal_zones_hash = {}
    
    # {ThermalZone1: number of people, ...}
    max_occ_on_thermal_zone = {}

    model.getThermalZones.each do |thermal_zone|

      # {ScheduleRuleset: number of people}
      occ_schedules_num_occ = {}
      max_occ_on_thermal_zone[thermal_zone] = 0
      # This block gets the total number of people on each schedule used by a zone
      #
      # [@Returns] a hash of {Schedule: number of people}
      #
      # Get the people objects
      thermal_zone.spaces.each do |space|
        # From the space type
        if space.spaceType.is_initialized
          space.spaceType.get.people.each do |people|
            num_ppl_sch = people.numberofPeopleSchedule
            if num_ppl_sch.is_initialized
              num_ppl_sch = num_ppl_sch.get
              num_ppl_sch = num_ppl_sch.to_ScheduleRuleset
              next if num_ppl_sch.empty? # Skip non-ruleset schedules
              num_ppl_sch = num_ppl_sch.get
              num_ppl = people.getNumberOfPeople(space.floorArea)
              if occ_schedules_num_occ[num_ppl_sch].nil?
                occ_schedules_num_occ[num_ppl_sch] = num_ppl
              else
                occ_schedules_num_occ[num_ppl_sch] += num_ppl
              end
              max_occ_on_thermal_zone[thermal_zone] += num_ppl #MAS should be equal above
            end
          end
        end
        # From the space
        space.people.each do |people|
          num_ppl_sch = people.numberofPeopleSchedule
          if num_ppl_sch.is_initialized
            num_ppl_sch = num_ppl_sch.get
            num_ppl_sch = num_ppl_sch.to_ScheduleRuleset
            next if num_ppl_sch.empty? # Skip non-ruleset schedules
            num_ppl_sch = num_ppl_sch.get
            num_ppl = people.getNumberOfPeople(space.floorArea)
            if occ_schedules_num_occ[num_ppl_sch].nil?
              occ_schedules_num_occ[num_ppl_sch] = num_ppl
            else
              occ_schedules_num_occ[num_ppl_sch] += num_ppl
            end
            max_occ_on_thermal_zone[thermal_zone] += num_ppl
          end
        end
      end
      # puts("#{occ_schedules_num_occ.values} = #{max_occ_on_thermal_zone[thermal_zone]}, #{occ_schedules_num_occ.values.first - max_occ_on_thermal_zone[thermal_zone]}")
      if people_schedule_thermal_zones_hash[occ_schedules_num_occ].nil?
        people_schedule_thermal_zones_hash[occ_schedules_num_occ] = [thermal_zone]
      else
        people_schedule_thermal_zones_hash[occ_schedules_num_occ] << thermal_zone
      end

    end
    return people_schedule_thermal_zones_hash, max_occ_on_thermal_zone
  end

  def self.get_day_schedules(occ_schedules_num_occ, year)
    first_day_date = year.makeDate(1)
    last_day_date = year.makeDate(365)
    daily_occ_sch_num_ppl = []
    occ_schedules_num_occ.each do |occ_sch, num_occ|
      daily_occ_sch_num_ppl << [occ_sch.getDaySchedules(first_day_date, last_day_date), num_occ]
    end

    return daily_occ_sch_num_ppl
  end

  def self.thermal_zone_get_occupancy_schedule(model, occupied_percentage_threshold = 0.05)
    
    # {ThermalZone: ScheduleRuleset}
    thermal_zone_people_schedule_hash = {}

    people_schedule_thermal_zones_hash, max_occ_on_thermal_zone = get_occ_schedules_and_occupancy(model)
    people_schedule_thermal_zones_hash.each do |people_schedule_number_people_hash, thermal_zones_array|
    
      # occ_schedules_num_occ, max_occ_on_thermal_zone = get_occ_schedules_and_occupancy(thermal_zone)
      year = model.getYearDescription
      daily_occ_sch_num_ppl = get_day_schedules(people_schedule_number_people_hash, year)

      time_value_pairs = {}
      yearly_data = []
      yearly_times = OpenStudio::DateTimeVector.new
      yearly_values = []
      (1..365).each do |i|
        times_on_this_day = []
        os_date = year.makeDate(i)
        day_of_week = os_date.dayOfWeek.valueName

        # Get the unique time indices and corresponding day schedules
        occ_schedules_day_schs = {}
        day_sch_num_occ = {}
        daily_occ_sch_num_ppl.each do |occ_sch, num_occ|
          # Get the day schedules for this day
          # (there should only be one)
          day_schs = occ_sch[i - 1]
          day_schs.times.each do |time|
            times_on_this_day << time.toString
          end
          day_sch_num_occ[day_schs] = num_occ
        end

        # Determine the total fraction for the airloop at each time
        daily_times = []
        daily_os_times = []
        daily_values = []
        daily_occs = []
        times_on_this_day.uniq.sort.each do |time|
          os_time = OpenStudio::Time.new(time)
          os_date_time = OpenStudio::DateTime.new(os_date, os_time)
          # Total number of people at each time
          tot_occ_at_time = 0
          day_sch_num_occ.each do |day_sch, num_occ|
            occ_frac = day_sch.getValue(os_time)
            tot_occ_at_time += occ_frac * num_occ
          end

          # Total fraction for the airloop at each time
          max_occ = people_schedule_number_people_hash.values[0] #TODO check that this is always = max_occ_on_thermal_zone
          thermal_zone_occ_frac = tot_occ_at_time / max_occ
          occ_status = 0 # unoccupied
          if thermal_zone_occ_frac >= occupied_percentage_threshold
            occ_status = 1
          end

          # Add this data to the daily arrays
          daily_times << time
          daily_os_times << os_time
          daily_values << occ_status
          daily_occs << thermal_zone_occ_frac.round(2)
        end

        # Simplify the daily times to eliminate intermediate
        # points with the same value as the following point.
        simple_daily_times = []
        simple_daily_os_times = []
        simple_daily_values = []
        simple_daily_occs = []
        daily_values.each_with_index do |value, j|
          next if value == daily_values[j + 1]
          simple_daily_times << daily_times[j]
          simple_daily_os_times << daily_os_times[j]
          simple_daily_values << daily_values[j]
          simple_daily_occs << daily_occs[j]
        end

        # Store the daily values

        if time_value_pairs[[simple_daily_times, simple_daily_values]].nil?
          time_value_pairs[[simple_daily_times, simple_daily_values]] = [os_date]
        else
          time_value_pairs[[simple_daily_times, simple_daily_values]] << os_date
        end
        #MAS this doesn't appear to be used
        yearly_data << { 'date' => os_date, 'day_of_week' => day_of_week, 'times' => simple_daily_times, 'values' => simple_daily_values, 'daily_os_times' => simple_daily_os_times, 'daily_occs' => simple_daily_occs }
      end

      # Create a TimeSeries from the data
      # time_series = OpenStudio::TimeSeries.new(times, values, 'unitless')

      # Make a schedule ruleset
      # sch_name = "#{thermal_zone.name} Occ Sch"
      sch_ruleset = OpenStudio::Model::ScheduleRuleset.new(model)
      # sch_ruleset.setName(sch_name.to_s)

      # Default - All Occupied
      day_sch = sch_ruleset.defaultDaySchedule
      # day_sch.setName("#{sch_name} Default")
      day_sch.addValue(OpenStudio::Time.new(0, 24, 0, 0), 1)

      # Winter Design Day - All Occupied
      day_sch = OpenStudio::Model::ScheduleDay.new(model)
      sch_ruleset.setWinterDesignDaySchedule(day_sch)
      day_sch = sch_ruleset.winterDesignDaySchedule
      # day_sch.setName("#{sch_name} Winter Design Day")
      day_sch.addValue(OpenStudio::Time.new(0, 24, 0, 0), 1)

      # Summer Design Day - All Occupied
      day_sch = OpenStudio::Model::ScheduleDay.new(model)
      sch_ruleset.setSummerDesignDaySchedule(day_sch)
      day_sch = sch_ruleset.summerDesignDaySchedule
      # day_sch.setName("#{sch_name} Summer Design Day")
      day_sch.addValue(OpenStudio::Time.new(0, 24, 0, 0), 1)

      ## New schedule creation

      time_value_pairs.each do |key, dates|
        times, values = key[0], key[1]
        sch_rule = OpenStudio::Model::ScheduleRule.new(sch_ruleset)
        sch_rule.setApplyMonday(true)
        sch_rule.setApplyTuesday(true)
        sch_rule.setApplyWednesday(true)
        sch_rule.setApplyThursday(true)
        sch_rule.setApplyFriday(true)
        sch_rule.setApplySaturday(true)
        sch_rule.setApplySunday(true)
        # sch_rule.setName("#{sch_name} Rule")

        dates.map { |date| sch_rule.addSpecificDate(date) }
        day_sch = sch_rule.daySchedule

        times.each_with_index { |time, j|
          value = values[j]
          next if value == values[j + 1] # Don't add breaks if same value
          day_sch.addValue(OpenStudio::Time.new(time), value)
        }
      end

      # {ThermalZone => people schedule, ...
      thermal_zones_array.each { |thermal_zone| thermal_zone_people_schedule_hash[thermal_zone] = sch_ruleset }

    end

    return thermal_zone_people_schedule_hash #sch_ruleset
  end

  # returns a hash of arrays of hashes...of arrays
  def self.setpoints_thermal_zones_hash(model, zones)

    # {setpoint_type: [{setpoint_value => [ThermalZone1, ...]}, ...], ...}
    setpoints_thermal_zones_hash = {}

    # setpoint types
    # {setpoint_type: [setpoint_thermal_zones_hash, see below]}
    setpoints_thermal_zones_hash[:design_heat_t] = []
    setpoints_thermal_zones_hash[:design_cool_t] = []
    setpoints_thermal_zones_hash[:design_heat_rh] = []
    setpoints_thermal_zones_hash[:design_cool_rh] = []
    setpoints_thermal_zones_hash[:design_heat_t_occ] = []
    setpoints_thermal_zones_hash[:design_cool_t_occ] = []
    setpoints_thermal_zones_hash[:design_heat_rh_occ] = []
    setpoints_thermal_zones_hash[:design_cool_rh_occ] = []

    # setpoints
    # {setpoint => [array, of, thermal, zones], ...}
    heating_setpoints_thermal_zones_hash = {} 
    cooling_setpoints_thermal_zones_hash = {} 
    humid_setpoints_thermal_zones_hash = {} 
    dehum_setpoints_thermal_zones_hash = {} 
    occ_heating_setpoints_thermal_zones_hash = {} 
    occ_cooling_setpoints_thermal_zones_hash = {} 
    occ_humid_setpoints_thermal_zones_hash = {} 
    occ_dehum_setpoints_thermal_zones_hash = {} 

    zones.each do |id, zone_hash|

      # get thermal zone and occupancy
      if zone_hash.has_key?(:name) && model.getThermalZoneByName(zone_hash[:name]).is_initialized
        thermal_zone = model.getThermalZoneByName(zone_hash[:name]).get
      elsif model.getThermalZoneByName(id).is_initialized
        thermal_zone = model.getThermalZoneByName(id).get
      else
        puts("Did not find zone in model assciated with #{id}. Not connecting objects related to this zone.") #TODO runner.registerWarning
        next
      end
      occupied = thermal_zone.numberOfPeople.zero? ? false : true

      # heating setpoint
      heating_setpoint = zone_hash[:design_heat_t]
      unless heating_setpoint.nil?
        hash = 
          case occupied
          when false then heating_setpoints_thermal_zones_hash
          when true then occ_heating_setpoints_thermal_zones_hash
          end
        if hash[heating_setpoint].nil?
          hash[heating_setpoint] = [thermal_zone]
        else
          hash[heating_setpoint] << thermal_zone
        end
      end

      # cooling setpoint
      cooling_setpoint = zone_hash[:design_cool_t]
      unless cooling_setpoint.nil?        
        hash = 
          case occupied
          when false then cooling_setpoints_thermal_zones_hash
          when true then occ_cooling_setpoints_thermal_zones_hash
          end
        if hash[cooling_setpoint].nil?
          hash[cooling_setpoint] = [thermal_zone]
        else
          hash[cooling_setpoint] << thermal_zone
        end
      end

      # humidifying setpoint
      humid_setpoint = zone_hash[:design_heat_rh]
      unless humid_setpoint.nil?
        hash = 
          case occupied
          when false then humid_setpoints_thermal_zones_hash
          when true then occ_humid_setpoints_thermal_zones_hash
          end        
        if hash[humid_setpoint].nil?
          hash[humid_setpoint] = [thermal_zone]
        else
          hash[humid_setpoint] << thermal_zone
        end
      end

      # dehumidifying setpoint
      dehum_setpoint = zone_hash[:design_cool_rh]
      unless dehum_setpoint.nil?
        hash = 
          case occupied
          when false then dehum_setpoints_thermal_zones_hash
          when true then occ_dehum_setpoints_thermal_zones_hash
          end        
        if hash[dehum_setpoint].nil?
          hash[dehum_setpoint] = [thermal_zone]
        else
          hash[dehum_setpoint] << thermal_zone
        end
      end
        
    end

    # add hashes to hash
    setpoints_thermal_zones_hash[:design_heat_t] << heating_setpoints_thermal_zones_hash
    setpoints_thermal_zones_hash[:design_cool_t] << cooling_setpoints_thermal_zones_hash
    setpoints_thermal_zones_hash[:design_heat_rh] << humid_setpoints_thermal_zones_hash
    setpoints_thermal_zones_hash[:design_cool_rh] << dehum_setpoints_thermal_zones_hash
    setpoints_thermal_zones_hash[:design_heat_t_occ] << occ_heating_setpoints_thermal_zones_hash
    setpoints_thermal_zones_hash[:design_cool_t_occ] << occ_cooling_setpoints_thermal_zones_hash
    setpoints_thermal_zones_hash[:design_heat_rh_occ] << occ_humid_setpoints_thermal_zones_hash
    setpoints_thermal_zones_hash[:design_cool_rh_occ] << occ_dehum_setpoints_thermal_zones_hash
    return setpoints_thermal_zones_hash

  end

  # adds setpoint schedules and thermostats to model
  def self.make_thermal_zone_thermostats(model, setpoints_thermal_zones_hash, thermal_zone_people_schedule_hash)

    setpoint_type = 'temperature'

    # heating
    setpoints_thermal_zones_hash[:design_heat_t].each do |setpoint_thermal_zones|
      setpoint_thermal_zones.each do |htg_setpoint_degF, thermal_zones_array|
        puts '', htg_setpoint_degF, thermal_zones_array.size
        htg_setpoint_degC = OpenStudio.convert(htg_setpoint_degF, 'F', 'C').get
        
        # schedule
        htg_sch = make_setpoint_schedule(model, setpoint: htg_setpoint_degC, type: setpoint_type, subtype: 'Heating')

        # thermostat
        thermal_zones_array.each do |thermal_zone|
          make_thermostat(thermal_zone, htg_sch, setpoint: htg_setpoint_degC, subtype: 'Heating')
        end

      end
    end

    # heating, occupied
    setpoints_thermal_zones_hash[:design_heat_t_occ].each do |setpoint_thermal_zones|
      setpoint_thermal_zones.each do |htg_setpoint_degF, thermal_zones_array|
        puts '', htg_setpoint_degF, thermal_zones_array.size
        htg_setpoint_degC = OpenStudio.convert(htg_setpoint_degF, 'F', 'C').get
        
        # schedule
        htg_sch = make_setpoint_schedule(model, setpoint: htg_setpoint_degC, type: setpoint_type, subtype: 'Heating')

        # thermostat
        thermal_zones_array.each do |thermal_zone|
          people_schedule = thermal_zone_people_schedule_hash[thermal_zone]
          make_thermostat(thermal_zone, htg_sch, setpoint: htg_setpoint_degC, subtype: 'Heating', people_schedule: people_schedule)
        end

      end
    end

    # cooling
    setpoints_thermal_zones_hash[:design_cool_t].each do |setpoint_thermal_zones| 
      setpoint_thermal_zones.each do |clg_setpoint_degF, thermal_zones_array|
        puts '', clg_setpoint_degF, thermal_zones_array.size
        clg_setpoint_degC = OpenStudio.convert(clg_setpoint_degF, 'F', 'C').get

        # schedule
        clg_sch = make_setpoint_schedule(model, setpoint: clg_setpoint_degC, type: setpoint_type, subtype: 'Cooling')
        
        # thermostat
        thermal_zones_array.each do |thermal_zone|
          make_thermostat(thermal_zone, clg_sch, setpoint: clg_setpoint_degC, subtype: 'Cooling')
        end

      end
    end

    # cooling, occupied
    setpoints_thermal_zones_hash[:design_cool_t_occ].each do |setpoint_thermal_zones| 
      setpoint_thermal_zones.each do |clg_setpoint_degF, thermal_zones_array|
        puts '', clg_setpoint_degF, thermal_zones_array.size
        clg_setpoint_degC = OpenStudio.convert(clg_setpoint_degF, 'F', 'C').get
        
        # schedule
        clg_sch = make_setpoint_schedule(model, setpoint: clg_setpoint_degC, type: setpoint_type, subtype: 'Cooling')

        # thermostat
        thermal_zones_array.each do |thermal_zone|
          people_schedule = thermal_zone_people_schedule_hash[thermal_zone]
          make_thermostat(thermal_zone, clg_sch, setpoint: clg_setpoint_degC, subtype: 'Cooling', people_schedule: people_schedule)
        end

      end
    end

  end

  # adds a thermostat to model and adjusts the setpoint schedule if occupied
  # assumes a 5F temperature setback for occupied zones
  # setbacks are enabled when zone occupancy is below 0.05, and disabled 1.5 hours before zone occupancy exceeds 0.05
  def self.make_thermostat(thermal_zone, setpoint_schedule, setpoint:, subtype:, people_schedule: false)

    if thermal_zone.thermostatSetpointDualSetpoint.is_initialized
      thermostat = thermal_zone.thermostatSetpointDualSetpoint.get
    else
      thermostat = OpenStudio::Model::ThermostatSetpointDualSetpoint.new(thermal_zone.model)
      thermal_zone.setThermostatSetpointDualSetpoint(thermostat)
    end
    # puts "#{thermal_zone.name} = #{htg_sch.name}" 

    if people_schedule
      # zone_occ_sch = thermal_zone_people_schedule_hash[thermal_zone]
      setback = 
        case subtype
        when 'Heating' then setpoint - OpenStudio.convert(5.0, 'R', 'K').get
        when 'Cooling' then setpoint + OpenStudio.convert(5.0, 'R', 'K').get
        end
      setpoint_schedule = OsLib_Schedules.merge_schedule_rulesets(setpoint_schedule, people_schedule) #bm.report('OsLib_Schedules.merge_schedule_rulesets') { }
      setpoint_schedule = OsLib_Schedules.schedule_ruleset_edit(setpoint_schedule, new_value_map: [[0.0, setback], [1.0, setpoint]], start_time_diff: 90)
      # puts "#{thermal_zone.name} = #{zone_occ_sch.name}"
    end

    thermostat.send("set#{subtype}SetpointTemperatureSchedule", setpoint_schedule)

  end

  # adds a setpoint schedule to model
  def self.make_setpoint_schedule(model, setpoint:, type:, subtype:)
      
    options = { 'name' => "#{subtype} Setpoint Schedule",
                'default_day' => ["#{subtype} Setpoint Default Day Schedule", [24.0, setpoint]],
                'winter_design_day' => [[24.0, setpoint]],
                'summer_design_day' => [[24.0, setpoint]] }
    schedule = OsLib_Schedules.createComplexSchedule(model, options)
    
    unless type == 'relative_humidity'
      if model.getScheduleTypeLimitsByName('Temperature Schedule Type Limits').is_initialized
        schedule.setScheduleTypeLimits(model.getScheduleTypeLimitsByName('Temperature Schedule Type Limits').get)
      end
    end

    return schedule

  end

  # adds setpoint schedules and humidistats to model
  def self.make_thermal_zone_humidistats(model, setpoints_thermal_zones_hash, thermal_zone_people_schedule_hash)
  
    setpoint_type = 'relative_humidity'

    # humidifying
    setpoints_thermal_zones_hash[:design_heat_rh].each do |setpoints_thermal_zones|
      setpoints_thermal_zones.each do |humid_setpoint_pct, thermal_zones_array|
        puts humid_setpoint_pct, thermal_zones_array.size
        humid_setpoint = humid_setpoint_pct * 100

        # schedule
        setpoint_schedule = make_setpoint_schedule(model, setpoint: humid_setpoint, type: setpoint_type, subtype: 'Humidifying')

        # humidistat
        thermal_zones_array.each do |thermal_zone|
          make_humidstat(thermal_zone, setpoint_schedule, setpoint: humid_setpoint, subtype: 'Humidifying')
        end
      
      end
    end

    # humidifying, occupied
    setpoints_thermal_zones_hash[:design_heat_rh_occ].each do |setpoints_thermal_zones|
      setpoints_thermal_zones.each do |humid_setpoint_pct, thermal_zones_array|
        puts humid_setpoint_pct, thermal_zones_array.size
        setpoint = humid_setpoint_pct * 100

        # schedule
        setpoint_schedule = make_setpoint_schedule(model, setpoint: setpoint, type: setpoint_type, subtype: 'Humidifying')

        # humidistat
        thermal_zones_array.each do |thermal_zone|
          people_schedule = thermal_zone_people_schedule_hash[thermal_zone]
          make_humidstat(thermal_zone, setpoint_schedule, setpoint: setpoint, subtype: 'Humidifying', people_schedule: people_schedule)            
        end
      
      end
    end

    # dehumidifying
    setpoints_thermal_zones_hash[:design_cool_rh].each do |setpoints_thermal_zones|
      setpoints_thermal_zones.each do |dehumid_setpoint_pct, thermal_zones_array|
        puts dehumid_setpoint_pct, thermal_zones_array.size
        setpoint = dehumid_setpoint_pct * 100

        # schedule
        setpoint_schedule = make_setpoint_schedule(model, setpoint: setpoint, type: setpoint_type, subtype: 'Dehumidifying')

        # humidistat
        thermal_zones_array.each do |thermal_zone|
          make_humidstat(thermal_zone, setpoint_schedule, setpoint: setpoint, subtype: 'Humidifying')
        end
      
      end
    end

    # dehumidifying, occupied
    setpoints_thermal_zones_hash[:design_cool_rh_occ].each do |setpoints_thermal_zones|
      setpoints_thermal_zones.each do |dehumid_setpoint_pct, thermal_zones_array|
        puts dehumid_setpoint_pct, thermal_zones_array.size
        setpoint = dehumid_setpoint_pct * 100

        # schedule
        setpoint_schedule = make_setpoint_schedule(model, setpoint: setpoint, type: setpoint_type, subtype: 'Dehumidifying')

        # humidistat
        thermal_zones_array.each do |thermal_zone|
          people_schedule = thermal_zone_people_schedule_hash[thermal_zone]
          make_humidstat(thermal_zone, setpoint_schedule, setpoint: setpoint, subtype: 'Humidifying', people_schedule: people_schedule)            
        end
      
      end
    end

  end

  # adds a humidistat to model and adjusts the setpoint schedule if occupied
  # assumes a setback of 0.0 when humidifying and 100.0 when dehumidifying
  # setbacks are enabled when zone occupancy is below 0.05, and disabled 1.5 hours before zone occupancy exceeds 0.05
  def self.make_humidstat(thermal_zone, setpoint_schedule, setpoint:, subtype:, people_schedule: false)

    if thermal_zone.zoneControlHumidistat.is_initialized
      humidistat = thermal_zone.zoneControlHumidistat.get
    else
      humidistat = OpenStudio::Model::ZoneControlHumidistat.new(thermal_zone.model)
      thermal_zone.setZoneControlHumidistat(humidistat)
    end

    if people_schedule
      setback = 
        case subtype
        when 'Humidifying' then 0.0
        when 'Dehumidifying' then 100.0
        end
      setpoint_schedule = OsLib_Schedules.merge_schedule_rulesets(setpoint_schedule, people_schedule)
      setpoint_schedule = OsLib_Schedules.schedule_ruleset_edit(setpoint_schedule, new_value_map: [[0.0, setback], [1.0, setpoint]], start_time_diff: 90)
    end
    humidistat.send("set#{subtype}RelativeHumiditySetpointSchedule", setpoint_schedule)

  end

  # primary method that calls other methods to add objects
  def self.add_objects_from_adv_import_hash(runner, model, advanced_inputs)

    # add schedule type limits
    OsLib_Schedules.addScheduleTypeLimits(model)

    # make schedules
    schedules = import_schs(runner, model, advanced_inputs[:building_type], advanced_inputs[:schedules], advanced_inputs[:week_schedules], advanced_inputs[:day_schedules])

    # make schedules sets
    schedule_sets = import_sch_set(runner, model, advanced_inputs[:schedule_sets], schedules)

    # make load defs
    lights = import_lights(runner, model, advanced_inputs[:light_defs])
    elec_equipment = import_elec_equipment(runner, model, advanced_inputs[:equip_defs])
    people = import_people(runner, model, advanced_inputs[:people_defs])

    # make space load instances and assign schedule sets to spaces
    modified_spaces = assign_space_attributes(runner, model, advanced_inputs[:spaces], schedule_sets, lights, elec_equipment, people)

    # add thermostats
    modified_zones = assign_zone_attributes(runner, model, advanced_inputs[:zones])

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
        runner.registerWarning("Did not find space in model assciated with #{id}. Not connecting objects related to this space.")
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

        if space_data[:people_defs].has_key?('people_heat_gain_total')
          activity_btu_h = space_data[:people_defs]['people_heat_gain_total']
          if space_data[:people_defs].has_key?('people_heat_gain_sensible')
            sensible_btu_h = space_data[:people_defs]['people_heat_gain_sensible']
            load_def.setSensibleHeatFraction(sensible_btu_h / activity_btu_h)
          end
          activity_w = OpenStudio.convert(activity_btu_h, 'Btu/h', 'W').get
          # assign or create schedule
          if model.getScheduleRulesetByName("activity_#{activity_w}").is_initialized
            sch_ruleset = model.getScheduleRulesetByName("activity_#{activity_w}").get
          else
            options = {'name' => "activity_#{activity_w}",
                       'defaultTimeValuePairs' => { 24.0 => activity_w },
                       'winterTimeValuePairs' => { 24.0 => 0 },
                       'summerTimeValuePairs' => { 24.0 => activity_w }
            }
            sch_ruleset = OsLib_Schedules.createSimpleSchedule(model, options)
          end
        else
          # create default activity level if one doesn't exist
          default_activity = 120.0
          options = {'name' => "activity_#{default_activity}",
                     'defaultTimeValuePairs' => { 24.0 => default_activity },
                     'winterTimeValuePairs' => { 24.0 => 0 },
                     'summerTimeValuePairs' => { 24.0 => default_activity }
          }
          sch_ruleset = OsLib_Schedules.createSimpleSchedule(model, options)
          runner.registerWarning("Did not find data for acitivty schedule, adding default of #{default_activity} W.")
        end
        load_inst.setActivityLevelSchedule(sch_ruleset)
      end

      # create infiltration load instances
      if space_data.has_key?(:infiltration_def)
        load_inst = OpenStudio::Model::SpaceInfiltrationDesignFlowRate.new(model)
        # include guard clause for valid infiltration input
        unless space_data[:infiltration_def][:infiltration_flow_per_space].nil?
          value_m3_s = OpenStudio.convert(space_data[:infiltration_def][:infiltration_flow_per_space], 'cfm', 'm^3/s').get
          load_inst.setDesignFlowRate(value_m3_s)
        end
        unless space_data[:infiltration_def][:infiltration_flow_per_space_area].nil?
          value_m_s = OpenStudio.convert(space_data[:infiltration_def][:infiltration_flow_per_space_area], 'cfm/ft^2', 'm/s').get
          load_inst.setFlowperSpaceFloorArea(value_m_s)
        end
        unless space_data[:infiltration_def][:infiltration_flow_per_exterior_surface_area].nil?
          value_m_s = OpenStudio.convert(space_data[:infiltration_def][:infiltration_flow_per_exterior_surface_area], 'cfm/ft^2', 'm/s').get
          load_inst.setFlowperExteriorSurfaceArea(value_m_s)
        end
        unless space_data[:infiltration_def][:infiltration_flow_per_exterior_wall_area].nil?
          value_m_s = OpenStudio.convert(space_data[:infiltration_def][:infiltration_flow_per_exterior_wall_area], 'cfm/ft^2', 'm/s').get
          load_inst.setFlowperExteriorWallArea(value_m_s)
        end
        unless space_data[:infiltration_def][:infiltration_flow_air_changes_per_hour].nil?
          load_inst.setAirChangesperHour(space_data[:infiltration_def][:infiltration_flow_air_changes_per_hour])
        end

        load_inst.setName("#{space.name.to_s}_infiltration")
        load_inst.setSpace(space)
        # infiltration schedule will be set to 0.25 when HVAC system is operational in HVAC section of code
        # set default always on here in case no HVAC system is present in the space
        load_inst.setSchedule(model.alwaysOnDiscreteSchedule)
        modified = true
      end

      # create ventilation instances
      if space_data.has_key?(:ventilation_def)
        vent_inst = OpenStudio::Model::DesignSpecificationOutdoorAir.new(model)
        # include guard clause for valid ventilation input
        value_person = OpenStudio.convert(space_data[:ventilation_def][:ventilation_flow_per_person], 'cfm', 'm^3/s').get
        value_area = OpenStudio.convert(space_data[:ventilation_def][:ventilation_flow_per_area], 'cfm/ft^2', 'm/s').get
        # value_space = OpenStudio.convert(space_data[:ventilation_def][:ventilation_flow_per_space], 'cfm', 'm^3/s').get
        # vent_inst.setOutdoorAirFlowRate(value_m3_s)
        value_ach = space_data[:ventilation_def][:ventilation_flow_air_changes_per_hour]
        outdoor_airflow_method = space_data[:ventilation_def][:outdoor_airflow_method]
        case outdoor_airflow_method
        when "SumPeopleAndArea"
          vent_inst.setOutdoorAirMethod("Sum")
          vent_inst.setOutdoorAirFlowperPerson(value_person)
          vent_inst.setOutdoorAirFlowperFloorArea(value_area)
        when "MaxPeopleAndArea"
          vent_inst.setOutdoorAirMethod("Maximum")
          vent_inst.setOutdoorAirFlowperPerson(value_person)
          vent_inst.setOutdoorAirFlowperFloorArea(value_area)
        when "MaxAirChangesPerHourAndSumPeopleAndArea"
          vent_inst.setOutdoorAirMethod("Maximum")
          vent_inst.setOutdoorAirFlowperPerson(value_person)
          vent_inst.setOutdoorAirFlowperFloorArea(value_area)
          vent_inst.setOutdoorAirFlowAirChangesperHour(value_ach)
        when "MaxAirChangesPerHourAndPeopleAndArea"
          vent_inst.setOutdoorAirMethod("Maximum")
          vent_inst.setOutdoorAirFlowperPerson(value_person)
          vent_inst.setOutdoorAirFlowperFloorArea(value_area)
          vent_inst.setOutdoorAirFlowAirChangesperHour(value_ach)
        when "AirChangesPerHour"
          vent_inst.setOutdoorAirMethod("Maximum")
          vent_inst.setOutdoorAirFlowAirChangesperHour(value_ach)
        end
        vent_inst.setName("#{space.name.to_s}_ventilation")
        space.setDesignSpecificationOutdoorAir(vent_inst)
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

  # assign newly made space objects to existing spaces
  def self.assign_zone_attributes(runner, model, zones)

    thermal_zone_people_schedule_hash = thermal_zone_get_occupancy_schedule(model)
    setpoints_thermal_zones_hash = setpoints_thermal_zones_hash(model, zones)
    
    make_thermal_zone_thermostats(model, setpoints_thermal_zones_hash, thermal_zone_people_schedule_hash)
    make_thermal_zone_humidistats(model, setpoints_thermal_zones_hash, thermal_zone_people_schedule_hash)
    
    # modified_zones = {}
    # zones.each do |id, zone_data|

    #   modified = false

    #   # find model zone
    #   if zone_data.has_key?(:name) && model.getThermalZoneByName(zone_data[:name]).is_initialized
    #     zone = model.getThermalZoneByName(zone_data[:name]).get
    #   elsif model.getThermalZoneByName(id).is_initialized
    #     zone = model.getThermalZoneByName(id).get
    #   else
    #     runner.registerWarning("Did not find zone in model assciated with #{id}. Not connecting objects related to this zone.")
    #     next
    #   end
      # bm.report('assign_zone_attributes - thermal_zone_get_occupancy_schedule') do
      # @zone_occupied = zone.numberOfPeople.zero? ? false : true
      # if @zone_occupied
      #   @zone_occ_sch = thermal_zone_people_schedule_hash[zone]
      # end
      # end
      # bm.report('assign_zone_attributes - thermostats') do
      # make and assign thermostat if requested
      # if zone_data.has_key?(:design_heat_t) || zone_data.has_key?(:design_cool_t)
      #   thermostatSetpointDualSetpoint = OpenStudio::Model::ThermostatSetpointDualSetpoint.new(model)
      #   zone.setThermostatSetpointDualSetpoint(thermostatSetpointDualSetpoint)
      #   modified = true
        # get occupancy schedule if zone is occupied
        # zone_occupied = zone.numberOfPeople.zero? ? false : true
        # if zone_occupied
        #   zone_occ_sch = self.thermal_zone_get_occupancy_schedule(zone)
        # end

        # # create and assign heating and cooling setpoint schedules
        # # apply 5F temperature setback for occupied zones
        # # setbacks enable when zone occupancy is below 0.05, and disable 1.5 hours before zone occupancy exceeds 0.05
        # if zone_data.has_key?(:design_heat_t)
        #   htg_setpoint_degF = zone_data[:design_heat_t]
        #   htg_setpoint_degC = OpenStudio.convert(htg_setpoint_degF, 'F', 'C').get
        #   options = { 'name' => "htg_#{zone.name.to_s}",
        #               'default_day' => ["htg_#{zone.name.to_s}_default", [24.0, htg_setpoint_degC]],
        #               'winter_design_day' => [[24.0, htg_setpoint_degC]],
        #               'summer_design_day' => [[24.0, htg_setpoint_degC]] }
        #   @htg_sch = OsLib_Schedules.createComplexSchedule(model, options) #bm.report('OsLib_Schedules.createComplexSchedule') { }
        #   if model.getScheduleTypeLimitsByName('Temperature Schedule Type Limits').is_initialized
        #     @htg_sch.setScheduleTypeLimits(model.getScheduleTypeLimitsByName('Temperature Schedule Type Limits').get)
        #   end
        #   @htg_sch.setName("#{zone.name} Htg Setpoint Schedule")
        #   if @zone_occupied
        #     htg_setback_degC = htg_setpoint_degC - OpenStudio.convert(5.0, 'R', 'K').get
        #     @htg_sch = OsLib_Schedules.merge_schedule_rulesets(@htg_sch, @zone_occ_sch) #bm.report('OsLib_Schedules.merge_schedule_rulesets') { }
        #     @htg_sch = OsLib_Schedules.schedule_ruleset_edit(@htg_sch, new_value_map: [[0.0, htg_setback_degC], [1.0, htg_setpoint_degC]], start_time_diff: 90)
        #     # bm.report('OsLib_Schedules.schedule_ruleset_edit') { }
        #     @htg_sch.setName("#{zone.name} Htg Setpoint Schedule with Setback")
        #   end
        #   thermostatSetpointDualSetpoint.setHeatingSetpointTemperatureSchedule(@htg_sch)
        #   runner.registerInfo("Set heating setpoint schedule '#{@htg_sch.name}' for thermal zone '#{zone.name}'.")
        #   # end
        # end
        # if zone_data.has_key?(:design_cool_t)
        #   clg_setpoint_degF = zone_data[:design_cool_t]
        #   clg_setpoint_degC = OpenStudio.convert(clg_setpoint_degF, 'F', 'C').get
        #   options = { 'name' => "clg_#{zone.name.to_s}",
        #               'default_day' => ["clg_#{zone.name.to_s}_default", [24.0, clg_setpoint_degC]],
        #               'winter_design_day' => [[24.0, clg_setpoint_degC]],
        #               'summer_design_day' => [[24.0, clg_setpoint_degC]] }
        #   clg_sch = OsLib_Schedules.createComplexSchedule(model, options)
        #   if model.getScheduleTypeLimitsByName('Temperature Schedule Type Limits').is_initialized
        #     clg_sch.setScheduleTypeLimits(model.getScheduleTypeLimitsByName('Temperature Schedule Type Limits').get)
        #   end
        #   clg_sch.setName("#{zone.name} Clg Setpoint Schedule")
        #   if @zone_occupied
        #     clg_setback_degC = clg_setpoint_degC + OpenStudio.convert(5.0, 'R', 'K').get
        #     clg_sch = OsLib_Schedules.merge_schedule_rulesets(clg_sch, @zone_occ_sch)
        #     clg_sch = OsLib_Schedules.schedule_ruleset_edit(clg_sch, new_value_map: [[0.0, clg_setback_degC], [1.0, clg_setpoint_degC]], start_time_diff: 90)
        #     clg_sch.setName("#{zone.name} Clg Setpoint Schedule with Setback")
        #   end
        #   thermostatSetpointDualSetpoint.setCoolingSetpointTemperatureSchedule(clg_sch)
        #   runner.registerInfo("Set cooling setpoint schedule '#{clg_sch.name}' for thermal zone '#{zone.name}'.")
        # end
      # end
      # end
      # bm.report('assign_zone_attributes - humidistats') do
      # if zone_data.has_key?(:design_heat_rh) || zone_data.has_key?(:design_cool_rh)
      #   zone_control_humidistat = OpenStudio::Model::ZoneControlHumidistat.new(model)
      #   zone.setZoneControlHumidistat(zone_control_humidistat)
      #   modified = true # What does this do?

      #   # get occupancy schedule if zone is occupied
      #   # zone_occupied = zone.numberOfPeople.zero? ? false : true
      #   # if zone_occupied
      #   #   zone_occ_sch = self.thermal_zone_get_occupancy_schedule(zone)
      #   # end

      #   # create and assign heating and cooling setpoint schedules
      #   # apply 5F temperature setback for occupied zones
      #   # setbacks enable when zone occupancy is below 0.05, and disable 1.5 hours before zone occupancy exceeds 0.05
      #   if zone_data.has_key?(:design_heat_rh)
      #     humid_setpoint = zone_data[:design_heat_rh] * 100
      #     options = { 'name' => "humid_#{zone.name.to_s}",
      #                 'default_day' => ["humid#{zone.name.to_s}_default", [24.0, humid_setpoint]],
      #                 'winter_design_day' => [[24.0, humid_setpoint]],
      #                 'summer_design_day' => [[24.0, humid_setpoint]] }
      #     humid_sch = OsLib_Schedules.createComplexSchedule(model, options)
      #     # if model.getScheduleTypeLimitsByName('Temperature Schedule Type Limits').is_initialized
      #     #   humid_sch.setScheduleTypeLimits(model.getScheduleTypeLimitsByName('Temperature Schedule Type Limits').get)
      #     # end
      #     humid_sch.setName("#{zone.name} Humdification Setpoint Schedule")
      #     if @zone_occupied
      #       humid_setback = 0.0
      #       humid_sch = OsLib_Schedules.merge_schedule_rulesets(humid_sch, @zone_occ_sch)
      #       humid_sch = OsLib_Schedules.schedule_ruleset_edit(humid_sch, new_value_map: [[0.0, humid_setback], [1.0, humid_setpoint]], start_time_diff: 90)
      #     end
      #     zone_control_humidistat.setHumidifyingRelativeHumiditySetpointSchedule(humid_sch)
      #     runner.registerInfo("Set humidification setpoint schedule '#{humid_sch.name}' for thermal zone '#{zone.name}'.")
      #   end
      #   if zone_data.has_key?(:design_cool_rh)
      #     dehumid_setpoint = zone_data[:design_cool_rh] * 100
      #     options = { 'name' => "dehumid_#{zone.name.to_s}",
      #                 'default_day' => ["dehumid_#{zone.name.to_s}_default", [24.0, dehumid_setpoint]],
      #                 'winter_design_day' => [[24.0, dehumid_setpoint]],
      #                 'summer_design_day' => [[24.0, dehumid_setpoint]] }
      #     dehumid_sch = OsLib_Schedules.createComplexSchedule(model, options)
      #     # if model.getScheduleTypeLimitsByName('Temperature Schedule Type Limits').is_initialized
      #     #   clg_sch.setScheduleTypeLimits(model.getScheduleTypeLimitsByName('Temperature Schedule Type Limits').get)
      #     # end
      #     dehumid_sch.setName("#{zone.name} Dehumidification Setpoint Schedule")
      #     if @zone_occupied
      #       dehumid_setback = 100.0
      #       dehumid_sch = OsLib_Schedules.merge_schedule_rulesets(dehumid_sch, @zone_occ_sch)
      #       dehumid_sch = OsLib_Schedules.schedule_ruleset_edit(dehumid_sch, new_value_map: [[0.0, dehumid_setback], [1.0, dehumid_setpoint]], start_time_diff: 90)
      #     end
      #     zone_control_humidistat.setDehumidifyingRelativeHumiditySetpointSchedule(dehumid_sch)
      #     runner.registerInfo("Set dehumidification setpoint schedule '#{dehumid_sch.name}' for thermal zone '#{zone.name}'.")
      #   end
      # end
      # end
      # if modified add to modified_spaces hash
    #   if modified
    #     modified_zones[id] = zone
    #   end
    #   runner.registerInfo("Assigned new data to  #{modified_zones.size} existing zones in the model.")

    # end

    # return modified_zones
    # end
  end

  # create ruleset schedule from inputs
  def self.import_schs(runner, model, building_type, schedules, week_schedules, day_schedules)

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
      date_range = '1/1-12/31'
      # winter_design_day = nil
      # summer_design_day = nil
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
        days = BuildingTypeHelper.create_prefix_day_array(building_type)

        prefix_array = [day_type, date_range, days]
        rules << prefix_array + time_value_array
      end

      if BuildingTypeHelper.is_on_6_days(building_type)
        prefix_array = ["Sun", "1/1-12/31", "Sun"]
        time_value_array = [[7, 0.0], [9, 0.1], [13, 0.2], [16, 0.1], [24, 0.0]]
        rules << prefix_array + time_value_array
      elsif BuildingTypeHelper.is_on_5_days(building_type)
        prefix_array = ["Sun", "1/1-12/31", "Sun"]
        time_value_array = [[24, 0.0]]
        rules << prefix_array + time_value_array

        prefix_array = ["Sat", "1/1-12/31", "Sat"]
        time_value_array = [[7, 0.0], [9, 0.1], [13, 0.2], [16, 0.1], [24, 0.0]]
        rules << prefix_array + time_value_array
      end

      if building_type == "SchoolOrUniversity"
        prefix_array = ["January Break", "1/1-1/5", "Sun/Mon/Tue/Wed/Thu/Fri/Sat"]
        time_value_array = [[24, 0.0]]
        rules << prefix_array + time_value_array

        prefix_array = ["Spring Break", "4/4-4/13", "Sun/Mon/Tue/Wed/Thu/Fri/Sat"]
        time_value_array = [[24, 0.0]]
        rules << prefix_array + time_value_array

        prefix_array = ["Summer Break", "6/9-8/24", "Sun/Mon/Tue/Wed/Thu/Fri/Sat"]
        time_value_array = [[24, 0.0]]
        rules << prefix_array + time_value_array

        prefix_array = ["Winter Break", "12/16-12/31", "Sun/Mon/Tue/Wed/Thu/Fri/Sat"]
        time_value_array = [[24, 0.0]]
        rules << prefix_array + time_value_array
      end

      # populate schedule using schedule_data to update default profile and add rules to complex schedule
      options = { 'name' => ruleset_name,
                  # 'winter_design_day' => winter_design_day,
                  # 'summer_design_day' => summer_design_day,
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

    # create whole building infiltration schedule
    # todo - update schedule to be non-constant
    options = {'name' => "infil_bldg", 'default_day' => ["infil_bldg_default", [24.0, 1.0]]}
    infil_bldg_sch = OsLib_Schedules.createComplexSchedule(model, options)

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
      default_sch_set.setInfiltrationSchedule(infil_bldg_sch)
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

    # BigDecimal instantiation changed in Ruby 2.4.0
    # https://ruby-doc.org/stdlib-2.4.0/libdoc/bigdecimal/rdoc/BigDecimal.html
    if OpenStudio::VersionString.new(OpenStudio.openStudioVersion) < OpenStudio::VersionString.new('3.0.0') # Ruby < 2.2.4
      @zero = BigDecimal::new('0.0')
      @one = BigDecimal::new('1.0')
      @two = BigDecimal::new('2.0')
      @ten = BigDecimal::new('10.0')
    elsif OpenStudio::VersionString.new(OpenStudio.openStudioVersion) >= OpenStudio::VersionString.new('3.0.0') # Ruby >= 2.5.5
      @zero = BigDecimal('0.0')
      @one = BigDecimal('1.0')
      @two = BigDecimal('2.0')
      @ten = BigDecimal('10.0')
    end
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