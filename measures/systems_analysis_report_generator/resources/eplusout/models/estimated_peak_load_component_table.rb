module EPlusOut
  module Models
    EstimatedPeakLoadComponentTable = Struct.new(
        :name,
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
        :roof,
        :water_use_equipment,
        :zone_ventilation
    ) do
      include Models::Model

      def self.json_create(o)
        table = new(o['name'])
        estimated_peak_load_keys = o.keys - ['name']
        estimated_peak_load_keys.map { |key| table[key] = EstimatedPeakLoadComponent.new(*o[key].values) }
        table
      end

      def set_estimated_peak_load_component(load_type, load)
        self[load_type] = load
        normalize
      end

      def normalize
        recalculate_grand_total
        recalculate_percent_grand_totals
      end

      def excluded_members(excluded=[])
        self.members.reject { |member| excluded.include? member }
      end

      private
      def recalculate_percent_grand_totals
        excluded_members([:name, :grand_total]).map { |member| self[member].update_percent_grand_total(self.grand_total.total) }
      end

      def recalculate_grand_total
        load_members = excluded_members([:name, :grand_total])
        sensible_instant = load_members.inject(0) { |sum, member| sum += self[member].sensible_instant.to_f }
        sensible_delayed = load_members.inject(0) { |sum, member| sum += self[member].sensible_delayed.to_f }
        sensible_return_air = load_members.inject(0) { |sum, member| sum += self[member].sensible_return_air.to_f }
        latent = load_members.inject(0) { |sum, member| sum += self[member].latent.to_f }
        total = load_members.inject(0) { |sum, member| sum += self[member].total.to_f }

        self[:grand_total] = EstimatedPeakLoadComponent.new(nil, latent, nil, sensible_delayed, sensible_instant, sensible_return_air, total)
      end
    end
  end
end