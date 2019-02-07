module Mappers
  class Schedule < BaseMapper
    attr_accessor :gbxml, :mapper
    def initialize(gbxml, mapper, os_model)
      super(os_model)
      @gbxml = gbxml
      @mapper = mapper
    end

    def insert(gbxml_schedule)
      ruleset = OpenStudio::Model::ScheduleRuleset.new(@os_model)
      ruleset.setName(gbxml_schedule.name) if gbxml_schedule.name

      gbxml_schedule.year_schedules.each do |year_schedule|

        if year_schedule.week_schedule_id
          week_schedule = gbxml.week_schedules[year_schedule.week_schedule_id]
          week_schedule.days.each do |day|
            os_day_schedule = mapper.day_schedule.get(day.day_schedule_id_ref) unless day.day_schedule_id_ref.nil?

            next if os_day_schedule.nil?

            schedule_rule = OpenStudio::Model::ScheduleRule.new(ruleset, os_day_schedule)
            begin_date = year_schedule.begin_date
            schedule_rule.setStartDate(OpenStudio::Date.new(OpenStudio::MonthOfYear.new(begin_date.month), begin_date.day, begin_date.year))
            end_date = year_schedule.end_date
            schedule_rule.setEndDate(OpenStudio::Date.new(OpenStudio::MonthOfYear.new(end_date.month), end_date.day, end_date.year))

            schedule_rule.setApplySunday(true)
            schedule_rule.setApplyMonday(true)
            schedule_rule.setApplyTuesday(true)
            schedule_rule.setApplyWednesday(true)
            schedule_rule.setApplyThursday(true)
            schedule_rule.setApplyFriday(true)
            schedule_rule.setApplySaturday(true)
          end
        end
      end

      unless gbxml_schedule.id.nil?
        @loaded_objects[gbxml_schedule.id] = ruleset
      end

      ruleset
    end

    def get(id)
      if loaded_objects.has_key? id
        return loaded_objects[id]
      end
    end

  end
end