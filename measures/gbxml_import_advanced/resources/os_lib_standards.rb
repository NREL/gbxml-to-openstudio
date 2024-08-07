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

module OSLib_Standards
  module ThermalZone
    # This method creates a new fractional schedule ruleset.
    # If occupied_percentage_threshold is set, this method will return a discrete on/off fractional schedule
    # with a value of one when occupancy across all spaces is greater than or equal to the occupied_percentage_threshold,
    # and zero all other times.  Otherwise the method will return the weighted fractional occupancy schedule.
    #
    # @param thermal_zone [OpenStudio::Model::ThermalZone] OpenStudio ThermalZone object
    # @param sch_name [String] the name of the generated occupancy schedule
    # @param occupied_percentage_threshold [Double] the minimum fraction (0 to 1) that counts as occupied
    #   if this parameter is set, the returned ScheduleRuleset will be 0 = unoccupied, 1 = occupied
    #   otherwise the ScheduleRuleset will be the weighted fractional occupancy schedule
    # @return [<OpenStudio::Model::ScheduleRuleset>] OpenStudio ScheduleRuleset of fractional or discrete occupancy
    def self.thermal_zone_get_occupancy_schedule(thermal_zone, sch_name: nil, occupied_percentage_threshold: nil)
      if sch_name.nil?
        sch_name = "#{thermal_zone.name} Occ Sch"
      end
      # Get the occupancy schedule for all spaces in thermal_zone
      sch_ruleset = OSLib_Standards::Space.spaces_get_occupancy_schedule(thermal_zone.spaces,
                                                                             sch_name: sch_name,
                                                                             occupied_percentage_threshold: occupied_percentage_threshold)
      return sch_ruleset
    end

  end

  module Space
    # This method creates a new fractional schedule ruleset.
    # If occupied_percentage_threshold is set, this method will return a discrete on/off fractional schedule
    # with a value of one when occupancy across all spaces is greater than or equal to the occupied_percentage_threshold,
    # and zero all other times.  Otherwise the method will return the weighted fractional occupancy schedule.
    #
    # @param spaces [Array<OpenStudio::Model::Space>] array of spaces to generate occupancy schedule from
    # @param sch_name [String] the name of the generated occupancy schedule
    # @param occupied_percentage_threshold [Double] the minimum fraction (0 to 1) that counts as occupied
    #   if this parameter is set, the returned ScheduleRuleset will be 0 = unoccupied, 1 = occupied
    #   otherwise the ScheduleRuleset will be the weighted fractional occupancy schedule based on threshold_calc_method
    # @param threshold_calc_method [String] customizes behavior of occupied_percentage_threshold
    #   fractional passes raw value through,
    #   normalized_annual_range evaluates each value against the min/max range for the year
    #   normalized_daily_range evaluates each value against the min/max range for the day.
    #   The goal is a dynamic threshold that calibrates each day.
    # @return [<OpenStudio::Model::ScheduleRuleset>] a ScheduleRuleset of fractional or discrete occupancy
    def self.spaces_get_occupancy_schedule(spaces, sch_name: nil, occupied_percentage_threshold: nil, threshold_calc_method: 'value')
      if spaces.empty?
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.space', 'Empty spaces array passed to spaces_get_occupancy_schedule method.')
        return false
      end

      unless sch_name.nil?
        OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.space', "Finding space schedules for #{sch_name}.")
      end

      # create schedule
      if sch_name.nil?
        sch_name = "#{spaces.size} space(s) Occ Sch"
      end

      # Get all the occupancy schedules in spaces.
      # Include people added via the SpaceType and hard-assigned to the Space itself.
      occ_schedules_num_occ = {} # hash of People ScheduleRuleset => design occupancy for that People object
      spaces.each do |space|
        # From the space type
        if space.spaceType.is_initialized
          space.spaceType.get.people.each do |people|
            num_ppl_sch = people.numberofPeopleSchedule
            next if num_ppl_sch.empty?

            if num_ppl_sch.get.to_ScheduleRuleset.empty? # skip non-ruleset schedules
              OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.space', "People schedule #{num_ppl_sch.get.name} is not a Ruleset Schedule, it will not contribute to hours of operation")
            else
              num_ppl_sch = num_ppl_sch.get.to_ScheduleRuleset.get
              num_ppl = people.getNumberOfPeople(space.floorArea)
              occ_schedules_num_occ.key?(num_ppl_sch) ? occ_schedules_num_occ[num_ppl_sch] += num_ppl : occ_schedules_num_occ[num_ppl_sch] = num_ppl
            end
          end
        end

        # From the space
        space.people.each do |people|
          num_ppl_sch = people.numberofPeopleSchedule
          next if num_ppl_sch.empty?

          if num_ppl_sch.get.to_ScheduleRuleset.empty? # skip non-ruleset schedules
            OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.space', "People schedule #{num_ppl_sch.get.name} is not a Ruleset Schedule, it will not contribute to hours of operation")
          else
            num_ppl_sch = num_ppl_sch.get.to_ScheduleRuleset.get
            num_ppl = people.getNumberOfPeople(space.floorArea)
            occ_schedules_num_occ.key?(num_ppl_sch) ? occ_schedules_num_occ[num_ppl_sch] += num_ppl : occ_schedules_num_occ[num_ppl_sch] = num_ppl
          end
        end
      end

      OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.space', "The #{spaces.size} spaces have #{occ_schedules_num_occ.size} unique occ schedules.")
      occ_schedules_num_occ.each do |occ_sch, num_occ|
        OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.space', "...#{occ_sch.name} - #{num_occ.round} people")
      end

      # get nested array of 8760 values of the total occupancy at each hour of each schedule
      all_schedule_hourly_occ = []
      occ_schedules_num_occ.each do |occ_sch, num_occ|
        all_schedule_hourly_occ << OSLib_Standards::Schedules.schedule_get_hourly_values(occ_sch).map { |i| (i * num_occ).round(6) }
      end

      # total occupancy from all people
      total_design_occ = occ_schedules_num_occ.values.sum

      OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.space', "Total #{total_design_occ.round} people in #{spaces.size} spaces.")

      # if design occupancy is zero, return zero schedule
      if total_design_occ.zero?
        schedule_ruleset = OSLib_Standards::Schedules.create_constant_schedule_ruleset(spaces[0].model, 0.0, name: sch_name)
        return schedule_ruleset
      end

      # get one 8760 array of the sum of each schedule's hourly occupancy
      combined_hourly_occ = all_schedule_hourly_occ.transpose.map(&:sum)

      # divide each hourly value by total occupancy - this is all spaces fractional occupancy
      combined_occ_frac = combined_hourly_occ.map { |i| i / total_design_occ }

      # divide 8760 array into 365(or 366)x24 arrays
      daily_combined_occ_fracs = combined_occ_frac.each_slice(24).to_a

      # If occupied_percentage_threshold is specified, schedule values are boolean
      # Otherwise use the actual spaces_occ_frac
      if occupied_percentage_threshold.nil?
        occ_status_vals = daily_combined_occ_fracs
      elsif threshold_calc_method == 'normalized_daily_range'
        # calculate max/min values in each daily occ fraction array
        daily_max_vals = daily_combined_occ_fracs.map(&:max)
        daily_min_vals = daily_combined_occ_fracs.map(&:min)
        # normalize threshold to daily min/max values
        daily_normalized_thresholds = daily_min_vals.zip(daily_max_vals).map { |min_max| min_max[0] + ((min_max[1] - min_max[0]) * occupied_percentage_threshold) }
        # if daily occ frac exceeds daily normalized threshold, set value to 1
        occ_status_vals = daily_combined_occ_fracs.each_with_index.map { |day_array, i| day_array.map { |day_val| !day_val.zero? && day_val >= daily_normalized_thresholds[i] ? 1 : 0 } }
      elsif threshold_calc_method == 'normalized_annual_range'
        # calculate annual min/max values
        annual_max = daily_combined_occ_fracs.max_by(&:max).max
        annual_min = daily_combined_occ_fracs.min_by(&:min).min
        # normalize threshold to annual min/max
        annual_normalized_threshold = annual_min + ((annual_max - annual_min) * occupied_percentage_threshold)
        # if vals exceed threshold, set val to 1
        occ_status_vals = daily_combined_occ_fracs.map { |day_array| day_array.map { |day_val| day_val >= annual_normalized_threshold ? 1 : 0 } }
      else # threshold_calc_method == 'value'
        occ_status_vals = daily_combined_occ_fracs.map { |day_array| day_array.map { |day_val| day_val >= occupied_percentage_threshold ? 1 : 0 } }
      end

      # get unique daily profiles
      unique_profiles = occ_status_vals.uniq
      profile_days_hash = {} # hash of unique profile => array of day indeces
      unique_profiles.each do |day_profile|
        days_with_profile = occ_status_vals.each_with_index.filter_map { |day, i| i + 1 if day == day_profile }
        profile_days_hash[day_profile] = days_with_profile
      end

      # create schedule
      schedule_ruleset = OpenStudio::Model::ScheduleRuleset.new(spaces[0].model)
      schedule_ruleset.setName(sch_name.to_s)
      # add properties to schedule
      props = schedule_ruleset.additionalProperties
      props.setFeature('max_occ_in_spaces', total_design_occ)
      props.setFeature('number_of_spaces_included', spaces.size)
      # nothing uses this but can make user be aware if this may be out of sync with current state of occupancy profiles
      props.setFeature('date_parent_object_last_edited', Time.now.getgm.to_s)
      props.setFeature('date_parent_object_created', Time.now.getgm.to_s)

      # Winter Design Day - All Occupied
      schedule_ruleset.setWinterDesignDaySchedule(schedule_ruleset.winterDesignDaySchedule)
      day_sch = schedule_ruleset.winterDesignDaySchedule
      day_sch.setName("#{sch_name} Winter Design Day")
      day_sch.addValue(OpenStudio::Time.new(0, 24, 0, 0), 1)

      # Summer Design Day - All Occupied
      schedule_ruleset.setSummerDesignDaySchedule(schedule_ruleset.summerDesignDaySchedule)
      day_sch = schedule_ruleset.summerDesignDaySchedule
      day_sch.setName("#{sch_name} Summer Design Day")
      day_sch.addValue(OpenStudio::Time.new(0, 24, 0, 0), 1)

      # set most used profile to default day
      most_used_profile = profile_days_hash.max_by { |k, v| v.size }.first
      default_day = schedule_ruleset.defaultDaySchedule
      default_day.setName("#{sch_name} Default")
      OSLib_Standards::Schedules.schedule_day_populate_from_array_of_values(default_day, most_used_profile)

      # create rules from remaining profiles
      remaining_profiles = profile_days_hash.slice(*profile_days_hash.keys.reject { |k| k == most_used_profile })
      remaining_profiles.each do |profile, days_used|
        rules = OSLib_Standards::Schedules.schedule_ruleset_create_rules_from_day_list(schedule_ruleset, days_used)
        rules.each { |rule| OSLib_Standards::Schedules.schedule_day_populate_from_array_of_values(rule.daySchedule, profile) }
      end

      return schedule_ruleset
    end
  end

  module Schedules

    # Methods to create/modify/extract information from Schedule objects

    # create a ScheduleTypeLimits object for a schedule
    #
    # @param model [OpenStudio::Model::Model] OpenStudio model object
    # @param standard_schedule_type_limit [String] the name of a standard schedule type limit with predefined limits
    #   options are Dimensionless, Temperature, Humidity Ratio, Fraction, Fractional, OnOff, and Activity
    # @param name [String] the name of the schedule type limits
    # @param lower_limit_value [double] the lower limit value for the schedule type
    # @param upper_limit_value [double] the upper limit value for the schedule type
    # @param numeric_type [String] the numeric type, options are Continuous or Discrete
    # @param unit_type [String] the unit type, options are defined in EnergyPlus I/O reference
    # @return [OpenStudio::Model::ScheduleTypeLimits] OpenStudio ScheduleTypeLimits object
    def self.create_schedule_type_limits(model,
                                         standard_schedule_type_limit: nil,
                                         name: nil,
                                         lower_limit_value: nil,
                                         upper_limit_value: nil,
                                         numeric_type: nil,
                                         unit_type: nil)

      if standard_schedule_type_limit.nil?
        if lower_limit_value.nil? || upper_limit_value.nil? || numeric_type.nil? || unit_type.nil?
          OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Schedules.Create', 'If calling create_schedule_type_limits without a standard_schedule_type_limit, you must specify all properties of ScheduleTypeLimits.')
          return false
        end
        schedule_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
        schedule_type_limits.setName(name) if !name.nil?
        schedule_type_limits.setLowerLimitValue(lower_limit_value)
        schedule_type_limits.setUpperLimitValue(upper_limit_value)
        schedule_type_limits.setNumericType(numeric_type)
        schedule_type_limits.setUnitType(unit_type)
      else
        schedule_type_limits = model.getScheduleTypeLimitsByName(standard_schedule_type_limit)
        if schedule_type_limits.empty?
          case standard_schedule_type_limit.downcase
          when 'dimensionless'
            schedule_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
            schedule_type_limits.setName('Dimensionless')
            schedule_type_limits.setLowerLimitValue(0.0)
            schedule_type_limits.setUpperLimitValue(1000.0)
            schedule_type_limits.setNumericType('Continuous')
            schedule_type_limits.setUnitType('Dimensionless')

          when 'temperature'
            schedule_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
            schedule_type_limits.setName('Temperature')
            schedule_type_limits.setLowerLimitValue(0.0)
            schedule_type_limits.setUpperLimitValue(100.0)
            schedule_type_limits.setNumericType('Continuous')
            schedule_type_limits.setUnitType('Temperature')

          when 'humidity ratio'
            schedule_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
            schedule_type_limits.setName('Humidity Ratio')
            schedule_type_limits.setLowerLimitValue(0.0)
            schedule_type_limits.setUpperLimitValue(0.3)
            schedule_type_limits.setNumericType('Continuous')
            schedule_type_limits.setUnitType('Dimensionless')

          when 'fraction', 'fractional'
            schedule_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
            schedule_type_limits.setName('Fraction')
            schedule_type_limits.setLowerLimitValue(0.0)
            schedule_type_limits.setUpperLimitValue(1.0)
            schedule_type_limits.setNumericType('Continuous')
            schedule_type_limits.setUnitType('Dimensionless')

          when 'onoff'
            schedule_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
            schedule_type_limits.setName('OnOff')
            schedule_type_limits.setLowerLimitValue(0)
            schedule_type_limits.setUpperLimitValue(1)
            schedule_type_limits.setNumericType('Discrete')
            schedule_type_limits.setUnitType('Availability')

          when 'activity'
            schedule_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
            schedule_type_limits.setName('Activity')
            schedule_type_limits.setLowerLimitValue(70.0)
            schedule_type_limits.setUpperLimitValue(1000.0)
            schedule_type_limits.setNumericType('Continuous')
            schedule_type_limits.setUnitType('ActivityLevel')
          else
            OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Schedules.Create', 'Invalid standard_schedule_type_limit for method create_schedule_type_limits.')
            return false
          end
        else
          schedule_type_limits = schedule_type_limits.get
          if schedule_type_limits.name.to_s.downcase == 'temperature'
            schedule_type_limits.resetLowerLimitValue
            schedule_type_limits.resetUpperLimitValue
            schedule_type_limits.setNumericType('Continuous')
            schedule_type_limits.setUnitType('Temperature')
          end
        end
      end
      return schedule_type_limits
    end

    # Returns an array of average hourly values from a Schedule object
    # Returns 8760 values, 8784 for leap years.
    #
    # @param schedule [OpenStudio::Model::Schedule] OpenStudio Schedule object
    # @return [Array<Double>] Array of hourly values for the year
    def self.schedule_get_hourly_values(schedule)
      case schedule.iddObjectType.valueName.to_s
      when 'OS_Schedule_Ruleset'
        schedule = schedule.to_ScheduleRuleset.get
        result = OSLib_Standards::Schedules.schedule_ruleset_get_hourly_values(schedule)
      when 'OS_Schedule_Constant'
        schedule = schedule.to_ScheduleConstant.get
        result = OSLib_Standards::Schedules.schedule_constant_get_hourly_values(schedule)
      when 'OS_Schedule_Compact'
        schedule = schedule.to_ScheduleCompact.get
        result = OSLib_Standards::Schedules.schedule_compact_get_hourly_values(schedule)
      when 'OS_Schedule_Year'
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Schedules.Information', "#{__method__} does not yet support ScheduleYear schedules.")
        result = nil
      when 'OS_Schedule_Interval'
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Schedules.Information', "#{__method__} does not yet support ScheduleInterval schedules.")
        result = nil
      else
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Schedules.Information', "unrecognized schedule type #{schedule.iddObjectType.valueName} for #{__method__}.")
        result = nil
      end

      return result
    end

    # Returns an array of average hourly values from a ScheduleRuleset object
    # Returns 8760 values, 8784 for leap years.
    #
    # @param schedule_ruleset [OpenStudio::Model::ScheduleRuleset] OpenStudio ScheduleRuleset object
    # @return [Array<Double>] Array of hourly values for the year
    def self.schedule_ruleset_get_hourly_values(schedule_ruleset)
      # validate schedule
      unless schedule_ruleset.to_ScheduleRuleset.is_initialized
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Schedules.Information', "#{__method__} failed because object #{schedule_ruleset.name.get} is not a ScheduleRuleset.")
        return nil
      end

      model = schedule_ruleset.model

      # define the start and end date
      year_start_date = nil
      year_end_date = nil
      if model.yearDescription.is_initialized
        year_description = model.yearDescription.get
        year = year_description.assumedYear
        year_start_date = OpenStudio::Date.new(OpenStudio::MonthOfYear.new('January'), 1, year)
        year_end_date = OpenStudio::Date.new(OpenStudio::MonthOfYear.new('December'), 31, year)
      else
        OpenStudio.logFree(OpenStudio::Warn, 'openstudio.standards.Schedules.Information', 'Year description is not specified. Annual hours above value calculation will assume 2009, the default year OS uses.')
        year_start_date = OpenStudio::Date.new(OpenStudio::MonthOfYear.new('January'), 1, 2009)
        year_end_date = OpenStudio::Date.new(OpenStudio::MonthOfYear.new('December'), 31, 2009)
      end

      # Get the ordered list of all the day schedules
      day_schs = schedule_ruleset.getDaySchedules(year_start_date, year_end_date)

      # Loop through each day schedule and add its hours to total
      # @todo store the 24 hourly average values for each day schedule instead of recalculating for all days
      annual_hourly_values = []
      day_schs.each do |day_sch|
        # add daily average hourly values to annual hourly values array
        daily_hours = OSLib_Standards::Schedules.schedule_day_get_hourly_values(day_sch, model)
        annual_hourly_values += daily_hours
      end

      return annual_hourly_values
    end

    # Returns an array of average hourly values from a ScheduleConstant object
    # Returns 8760 values, 8784 for leap years.
    #
    # @param schedule_constant [OpenStudio::Model::ScheduleConstant] OpenStudio ScheduleConstant object
    # @return [Array<Double>] Array of hourly values for the year
    def self.schedule_constant_get_hourly_values(schedule_constant)
      hours = 8760
      hours += 24 if schedule_constant.model.getYearDescription.isLeapYear
      values = Array.new(hours) { schedule_constant.value }

      return values
    end

    # Returns an array of average hourly values from a ScheduleCompact object
    # Returns 8760 values, 8784 for leap years.
    #
    # @param schedule_compact [OpenStudio::Model::ScheduleCompact] OpenStudio ScheduleCompact object
    # @return [Array<Double>] Array of hourly values for the year
    def self.schedule_compact_get_hourly_values(schedule_compact)
      # set a ScheduleTypeLimits if none is present
      # this is required for the ScheduleTranslator instantiation
      unless schedule_compact.scheduleTypeLimits.is_initialized
        schedule_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
        schedule_compact.setScheduleTypeLimits(schedule_type_limits)
      end

      # convert to a ScheduleRuleset and use its method
      sch_translator = ScheduleTranslator.new(schedule_compact.model, schedule_compact)
      schedule_ruleset = sch_translator.convert_schedule_compact_to_schedule_ruleset
      result = OSLib_Standards::Schedules.schedule_ruleset_get_hourly_values(schedule_ruleset)

      return result
    end

    # Create constant ScheduleRuleset with a given value
    #
    # @param model [OpenStudio::Model::Model] OpenStudio model object
    # @param value [Double] the value to use, 24-7, 365
    # @param name [String] the name of the schedule
    # @param schedule_type_limit [String] the name of a schedule type limit
    #   options are Dimensionless, Temperature, Humidity Ratio, Fraction, Fractional, OnOff, and Activity
    # @return [OpenStudio::Model::ScheduleRuleset] OpenStudio ScheduleRuleset object
    def self.create_constant_schedule_ruleset(model,
                                              value,
                                              name: nil,
                                              schedule_type_limit: nil)
      # check to see if schedule exists with same name and constant value and return if true
      unless name.nil?
        existing_sch = model.getScheduleRulesetByName(name)
        if existing_sch.is_initialized
          existing_sch = existing_sch.get
          existing_day_sch_vals = existing_sch.defaultDaySchedule.values
          if existing_day_sch_vals.size == 1 && (existing_day_sch_vals[0] - value).abs < 1.0e-6
            return existing_sch
          end
        end
      end

      # create ScheduleRuleset
      schedule = OpenStudio::Model::ScheduleRuleset.new(model)
      schedule.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), value)

      # set name
      unless name.nil?
        schedule.setName(name)
        schedule.defaultDaySchedule.setName("#{name} Default")
      end

      # set schedule type limits
      if !schedule_type_limit.nil?
        sch_type_limits_obj = OSLib_Standards::Schedules.create_schedule_type_limits(model,
                                                                                         standard_schedule_type_limit: schedule_type_limit)
        schedule.setScheduleTypeLimits(sch_type_limits_obj)
      end

      return schedule
    end

    # Sets the values of a day schedule from an array of values
    # Clears out existing time value pairs and sets to supplied values
    #
    # @param schedule_day [OpenStudio::Model::ScheduleDay] The day schedule to set.
    # @param value_array [Array] Array of 24 values. Schedule times set based on value index. Identical values will be skipped.
    # @return [OpenStudio::Model::ScheduleDay]
    def self.schedule_day_populate_from_array_of_values(schedule_day, value_array)
      schedule_day.clearValues
      if value_array.size != 24
        OpenStudio.logFree(OpenStudio::Warn, 'openstudio.standards.Schedules.Modify', "#{__method__} expects value_array to contain 24 values, instead #{value_array.size} values were given. Resulting schedule will use first #{[24, value_array.size].min} values")
      end

      value_array[0..23].each_with_index do |value, h|
        next if value == value_array[h + 1]

        time = OpenStudio::Time.new(0, h + 1, 0, 0)
        schedule_day.addValue(time, value)
      end
      return schedule_day
    end

    # creates a minimal set of ScheduleRules that applies to all days in a given array of day of year indices
    #
    # @param schedule_ruleset [OpenStudio::Model::ScheduleRuleset]
    # @param days_used [Array] array of day of year integers
    # @param schedule_day [OpenStudio::Model::ScheduleDay] optional day schedule to apply to new rule. A new default schedule will be created for each rule if nil
    # @return [Array]
    def self.schedule_ruleset_create_rules_from_day_list(schedule_ruleset, days_used, schedule_day: nil)
      # get year from schedule_ruleset
      year = schedule_ruleset.model.getYearDescription.assumedYear

      # split day_used into sub arrays of consecutive days
      consec_days = days_used.chunk_while { |i, j| i + 1 == j }.to_a

      # split consec_days into sub arrays of consecutive weeks by checking that any value in next array differs by seven from a value in this array
      consec_weeks = consec_days.chunk_while { |i, j| i.product(j).any? { |x, y| (x - y).abs == 7 } }.to_a

      # make new rule for blocks of consectutive weeks
      rules = []
      consec_weeks.each do |week_group|
        if schedule_day.nil?
          OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.Parametric.ScheduleRuleset', 'Creating new Rule Schedule from days_used vector with new Day Schedule')
          rule = OpenStudio::Model::ScheduleRule.new(schedule_ruleset)
        else
          OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.Parametric.ScheduleRuleset', "Creating new Rule Schedule from days_used vector with clone of Day Schedule: #{schedule_day.name.get}")
          rule = OpenStudio::Model::ScheduleRule.new(schedule_ruleset, schedule_day)
        end

        # set day types and dates
        dates = week_group.flatten.map { |d| OpenStudio::Date.fromDayOfYear(d, year) }
        day_types = dates.map { |date| date.dayOfWeek.valueName }.uniq
        day_types.each { |type| rule.send("setApply#{type}", true) }
        rule.setStartDate(dates.min)
        rule.setEndDate(dates.max)

        rules << rule
      end

      return rules
    end

    # Sets the values of a day schedule from an array of values
    # Clears out existing time value pairs and sets to supplied values
    #
    # @param schedule_day [OpenStudio::Model::ScheduleDay] The day schedule to set.
    # @param value_array [Array] Array of 24 values. Schedule times set based on value index. Identical values will be skipped.
    # @return [OpenStudio::Model::ScheduleDay]
    def self.schedule_day_populate_from_array_of_values(schedule_day, value_array)
      schedule_day.clearValues
      if value_array.size != 24
        OpenStudio.logFree(OpenStudio::Warn, 'openstudio.standards.Schedules.Modify', "#{__method__} expects value_array to contain 24 values, instead #{value_array.size} values were given. Resulting schedule will use first #{[24, value_array.size].min} values")
      end

      value_array[0..23].each_with_index do |value, h|
        next if value == value_array[h + 1]

        time = OpenStudio::Time.new(0, h + 1, 0, 0)
        schedule_day.addValue(time, value)
      end
      return schedule_day
    end

    # Returns an array of average hourly values from a ScheduleDay object
    # Returns 24 values
    #
    # @param schedule_day [OpenStudio::Model::ScheduleDay] OpenStudio ScheduleDay object
    # @return [Array<Double>] Array of hourly values for the day
    def self.schedule_day_get_hourly_values(schedule_day, model = nil)
      schedule_values = []

      if model.nil?
        model = schedule_day.model
      end

      if model.version.str < '3.8.0'
        # determine smallest time interval
        times = schedule_day.times
        time_interval_min = 15.0
        previous_time_decimal = 0.0
        times.each_with_index do |time, i|
          time_decimal = (time.days * 24.0 * 60.0) + (time.hours * 60.0) + time.minutes + (time.seconds / 60)
          interval_min = time_decimal - previous_time_decimal
          time_interval_min = interval_min if interval_min < time_interval_min
          previous_time_decimal = time_decimal
        end
        time_interval_min = time_interval_min.round(0).to_i

        # get the hourly average by averaging the values in the hour at the smallest time interval
        (0..23).each do |j|
          values = []
          times = (time_interval_min..60).step(time_interval_min).to_a
          times.each { |t| values << schedule_day.getValue(OpenStudio::Time.new(0, j, t, 0)) }
          schedule_values << (values.sum / times.size).round(5)
        end
      else
        num_timesteps = model.getTimestep.numberOfTimestepsPerHour
        day_timeseries = schedule_day.timeSeries.values.to_a
        schedule_values = day_timeseries.each_slice(num_timesteps).map { |slice| slice.sum / slice.size.to_f }
      end

      unless schedule_values.size == 24
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.standards.Schedules.Information', "#{__method__} returned illegal number of values: #{schedule_values.size}.")
        return false
      end

      return schedule_values
    end
  end
end