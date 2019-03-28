module Mappers
  class ScheduleRuleset < BaseMapper
    @@instances = {}

    def initialize(os_model)
      super(os_model)
    end

    def insert(gbxml_schedule)
      ruleset = OpenStudio::Model::ScheduleRuleset.new(@os_model)
      ruleset.setName(gbxml_schedule.name) if gbxml_schedule.name

      gbxml_schedule.year_schedules.each do |year_schedule|

        next unless year_schedule.week_schedule_id
        week_schedule = GBXML::WeekSchedule.find(year_schedule.week_schedule_id)

        next unless week_schedule

        week_schedule.days.each do |day|
          os_day_schedule = Mappers::DaySchedule.find(day.day_schedule_id_ref) unless day.day_schedule_id_ref.nil?

          next unless os_day_schedule

          schedule_rule = OpenStudio::Model::ScheduleRule.new(ruleset, os_day_schedule)
          begin_date = year_schedule.begin_date
          schedule_rule.setStartDate(OpenStudio::Date.new(OpenStudio::MonthOfYear.new(begin_date.month), begin_date.day, begin_date.year))
          end_date = year_schedule.end_date
          schedule_rule.setEndDate(OpenStudio::Date.new(OpenStudio::MonthOfYear.new(end_date.month), end_date.day, end_date.year))

          next unless day.day_type
          ScheduleRuleset.apply_days_to_schedule_rule(schedule_rule, day.day_type)
        end
      end

      unless gbxml_schedule.id.nil?
        @@instances[gbxml_schedule.id] = ruleset
      end

      ruleset
    end

    def find(id)
      if @@instances.key?(id)
        return @@instances[id]
      end
    end

    def self.apply_days_to_schedule_rule(schedule_rule, day_type)
      if day_type == "All"
        schedule_rule.setApplySunday(true)
        schedule_rule.setApplyMonday(true)
        schedule_rule.setApplyTuesday(true)
        schedule_rule.setApplyWednesday(true)
        schedule_rule.setApplyThursday(true)
        schedule_rule.setApplyFriday(true)
        schedule_rule.setApplySaturday(true)
      elsif day_type == "Weekday"
        schedule_rule.setApplyMonday(true)
        schedule_rule.setApplyTuesday(true)
        schedule_rule.setApplyWednesday(true)
        schedule_rule.setApplyThursday(true)
        schedule_rule.setApplyFriday(true)
      elsif day_type == "Weekend"
        schedule_rule.setApplySunday(true)
        schedule_rule.setApplySaturday(true)
      elsif day_type == "Sun"
        schedule_rule.setApplySunday(true)
      elsif day_type == "Mon"
        schedule_rule.setApplyMonday(true)
      elsif day_type == "Tue"
        schedule_rule.setApplyTuesday(true)
      elsif day_type == "Wed"
        schedule_rule.setApplyWednesday(true)
      elsif day_type == "Thu"
        schedule_rule.setApplyThursday(true)
      elsif day_type == "Fri"
        schedule_rule.setApplyFriday(true)
      elsif day_type == "Sat"
        schedule_rule.setApplySaturday(true)
      end
    end
  end
end