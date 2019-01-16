class EngineeringCheckTable < JSONable
  attr_accessor :oa_percent, :airflow_per_floor_area, :airflow_per_total_cap, :floor_area_per_total_cap,
                :total_cap_per_floor_area, :number_of_people

  def initialize(options)
    @oa_percent = options[:oa_percent]
    @airflow_per_floor_area = options[:airflow_per_floor_area]
    @airflow_per_total_cap = options[:airflow_per_total_cap]
    @floor_area_per_total_cap = options[:floor_area_per_total_cap]
    @total_cap_per_floor_area = options[:total_cap_per_floor_area]
    @number_of_people = options[:number_of_people]
  end


end