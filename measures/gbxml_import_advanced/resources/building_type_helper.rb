class BuildingTypeHelper
  ON_7_DAY_TYPES = ["ConventionCenter", "DiningBarLoungeOrLeisure", "DiningCafeteriaFastFood", "DiningFamily", "Dormitory",
                    "ExerciseCenter", "FireStation", "Gymnasium", "HospitalOrHealthcare", "Hotel", "Motel", "MotionPictureTheatre",
                    "MultiFamily", "Museum", "Penitentiary", "PerformingArtsTheater", "Retail", "SingleFamily", "SportsArena", "Transportation"]

  ON_6_DAY_TYPES = ["ReligiousBuilding"]

  def self.create_prefix_day_array(building_type)
    if ON_7_DAY_TYPES.include? building_type
      return 'Mon/Tue/Wed/Thu/Fri/Sat/Sun'
    elsif ON_6_DAY_TYPES.include? building_type
      return 'Mon/Tue/Wed/Thu/Fri/Sat'
    else
      return 'Mon/Tue/Wed/Thu/Fri'
    end
  end

  def self.is_on_6_days(building_type)
    return ON_6_DAY_TYPES.include? building_type
  end

  def self.is_on_5_days(building_type)
    return !(ON_6_DAY_TYPES.include? building_type or ON_7_DAY_TYPES.include? building_type)
  end
end
