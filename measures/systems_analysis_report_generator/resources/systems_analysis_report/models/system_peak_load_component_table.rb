module SystemsAnalysisReport
  module Models
    SystemPeakLoadComponentTable = Struct.new(
        # :airflow_correction_factor,
        :doas_direct_to_zone,
        :equipment,
        :exterior_floor,
        :exterior_wall,
        :fenestration_conduction,
        :fenestration_solar,
        :grand_total,
        :ground_contact_floor,
        :ground_contact_wall,
        :hvac_equipment_loss,
        :infiltration,
        :interzone_ceiling,
        :interzone_floor,
        :interzone_mixing,
        :interzone_wall,
        :lights,
        :opaque_door,
        :other_floor,
        :other_roof,
        :other_wall,
        :people,
        :power_generation_equipment,
        :refrigeration,
        :return_air_other,
        :return_air_lights,
        :roof,
        :supply_fan_heat,
        :sizing_factor_correction,
        :time_delay_correction,
        :water_use_equipment,
        :zone_ventilation
    ) do

      include Models::Model

      def add_load(key, load)
        self[key] = load
      end

      def normalize
        recalculate_grand_total
        recalculate_percent_grand_totals
      end

      def excluded_members(excluded=[])
        self.members.reject { |member| excluded.include? member }
      end

      def floor_area
        members = [:exterior_floor, :ground_contact_floor, :interzone_floor, :other_floor]
        members.inject(0) { |sum, member| sum + self[member].related_area.to_f }
      end

      private
      def recalculate_percent_grand_totals
        excluded_members([:name, :grand_total]).map { |member| self[member].update_percent_grand_total(self.grand_total.total) if self[member] }
        load_members = excluded_members([:name, :grand_total])
        total_percent = load_members.inject(0) { |sum, member| sum + (self[member] ? self[member].percent_grand_total.to_f : 0)}
        self[:grand_total].percent_grand_total = total_percent
      end

      def recalculate_grand_total
        load_members = excluded_members([:name, :grand_total])
        sensible_instant = load_members.inject(0) { |sum, member| sum + (self[member] ? self[member].sensible_instant.to_f : 0)}
        sensible_delayed = load_members.inject(0) { |sum, member| sum + (self[member] ? self[member].sensible_delayed.to_f : 0)}
        latent = load_members.inject(0) { |sum, member| sum + (self[member] ? self[member].latent.to_f : 0)}
        total = load_members.inject(0) { |sum, member| sum + (self[member] ? self[member].total.to_f : 0)}

        self[:grand_total] = Models::PeakLoadComponent.new(sensible_instant, sensible_delayed, latent, total)
      end
    end
  end
end
