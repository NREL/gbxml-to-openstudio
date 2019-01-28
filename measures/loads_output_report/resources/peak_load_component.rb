require_relative 'jsonable'
# require 'json'

class PeakLoadComponent < JSONable
  attr_accessor :sensible_instant, :sensible_delayed, :sensible_return_air, :latent, :total, :percent_grand_total,
                :related_area, :total_per_area

  def initialize(options)
    @sensible_instant = options[:sensible_instant]
    @sensible_delayed = options[:sensible_delayed]
    @sensible_return_air = options[:sensible_return_air]
    @latent = options[:latent]
    @total = options[:total]
    @percent_grand_total = options[:percent_grand_total]
    @related_area = options[:related_area]
    @total_per_area = options[:total_per_area]
  end

  def ==(other)
    equal = true
    self.instance_variables.each do |variable|
      unless self.instance_variable_get(variable) == other.instance_variable_get(variable)
        equal = false
        break
      end
    end

    return equal
  end
end
