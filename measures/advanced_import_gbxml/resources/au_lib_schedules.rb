

module AuLib_Schedules

  # Changes the start time of an on off ScheduleRuleset and replace values
  #
  # @param sch [OpenStudio::Model::ScheduleRuleset] ScheduleRuleset
  # @param new_value_map [Array<Array<Double,Double>>] array of old and new value pairs
  #   e.g. [[1.0,0.25],[0.0,1.0]]
  # @param start_time_diff [Double] minutes to move up start time
  #   e.g. 90 means the schedule starts 90 minutes earlier
  #   if start time would move before midnight, start time set to midnight
  # @return [OpenStudio::Model::ScheduleRuleset] ScheduleRuleset with new values
  def self.schedule_ruleset_edit(sch, new_value_map: [], start_time_diff: 0)
    # get and store ScheduleDay objects
    schedule_days = []
    schedule_days << sch.defaultDaySchedule
    sch.scheduleRules.each do |sch_rule|
      schedule_days << sch_rule.daySchedule
    end

    # replace values in each ScheduleDay object
    schedule_days.each do |sch_day|
      # get times and values
      sch_times = sch_day.times
      sch_values = sch_day.values

      # replace values
      new_value_map.each do |pair|
        sch_values = sch_values.map { |x| x == pair[0] ? pair[1] : x }
      end

      # clear values and set new ones
      sch_day.clearValues
      sch_times.each_with_index do |time, i|
        if (i == 0) && (time.days < 1) && (time.hours < 24)
          minutes = (time.hours * 60.0) + time.minutes.to_f
          minutes -= start_time_diff
          # do not add the value if it extends before midnight
          unless minutes <= 0
            hours = (minutes / 60.0).floor
            minutes = (minutes - hours * 60.0).round(0)
            new_time = OpenStudio::Time.new(0, hours.to_i, minutes.to_i, 0)
            sch_day.addValue(new_time, sch_values[i])
          end
        else
          sch_day.addValue(time, sch_values[i])
        end
      end
    end

    return sch
  end

  # Merges two ScheduleRulesets, setting times and values of the first schedule from the second
  #
  # @param sch1 [OpenStudio::Model::ScheduleRuleset] ScheduleRuleset to use as base schedule
  # @param sch2 [OpenStudio::Model::ScheduleRuleset] ScheduleRuleset to inheret values from
  # @return [OpenStudio::Model::ScheduleRuleset] ScheduleRuleset with new values
  def self.merge_schedule_rulesets(sch1, sch2)
    sch1_default_day = sch1.defaultDaySchedule
    sch2_default_day = sch2.defaultDaySchedule

    # assign schedule2 default schedule time-values to schedule1
    sch1_default_day.clearValues
    sch_times = sch2_default_day.times
    sch_values = sch2_default_day.values
    sch_times.each_with_index do |time, i|
      sch1_default_day.addValue(time, sch_values[i])
    end

    # clear schedule rules from schedule1
    sch1.scheduleRules.each(&:remove)

    # assign schedule rules from schedule2 to schedule1
    sch2.scheduleRules.each do |sch2_rule|
      # get times and values
      sch2_day = sch2_rule.daySchedule
      sch_times = sch2_day.times
      sch_values = sch2_day.values

      # make new schedule rule for schedule1
      sch1_rule = create_schedule_rule(sch1) #OpenStudio::Model::ScheduleRule.new(sch1)
      sch1_rule.setName("#{sch1.name} Schedule Rule")
      sch1_sch_rule_day = sch1_rule.daySchedule
      sch1_sch_rule_day.clearValues
      sch_times.each_with_index do |time, i|
        sch1_sch_rule_day.addValue(time, sch_values[i])
      end

      # apply same days of week
      sch1_rule.setApplyMonday(true) if sch2_rule.applyMonday
      sch1_rule.setApplyTuesday(true) if sch2_rule.applyTuesday
      sch1_rule.setApplyWednesday(true) if sch2_rule.applyWednesday
      sch1_rule.setApplyThursday(true) if sch2_rule.applyThursday
      sch1_rule.setApplyFriday(true) if sch2_rule.applyFriday
      sch1_rule.setApplySaturday(true) if sch2_rule.applySaturday
      sch1_rule.setApplySunday(true) if sch2_rule.applySunday

      # apply same start and end dates
      sch1_rule.setStartDate(sch2_rule.startDate.get) if sch2_rule.startDate.is_initialized
      sch1_rule.setEndDate(sch2_rule.endDate.get) if sch2_rule.endDate.is_initialized
    end
    return sch1
  end

  def self.create_schedule_rule(schedule_ruleset)
    OpenStudio::Model::ScheduleRule.new(schedule_ruleset)
  end

end
