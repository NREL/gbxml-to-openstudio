class Helpers

  def self.get_plant_loop_by_id(model, id)
    model.getPlantLoops.each do |plant_loop|
      feature = plant_loop.additionalProperties.getFeatureAsString('id')
      if feature.is_initialized and feature.get == id
        return plant_loop
      end
    end
    return false
  end

  def self.get_air_loop_by_id(model, id)
    model.getAirLoopHVACs.each do |air_loop|
      feature = air_loop.additionalProperties.getFeatureAsString('id')
      if feature.is_initialized and feature.get == id
        return air_loop
      end
    end
    return false
  end

  def self.get_hvac_component_by_id(model, id)
    model.getHVACComponents.each do |hvac_component|
      feature = hvac_component.additionalProperties.getFeatureAsString('id')
      if feature.is_initialized and feature.get == id
        return hvac_component
      end
    end
    return false
  end

  def self.get_thermal_zone_by_cad_object_id(model, cad_object_id)
    model.getThermalZones.each do |thermal_zone|
      feature = thermal_zone.additionalProperties.getFeatureAsString('CADObjectId')
      if feature.is_initialized and feature.get == cad_object_id
        return thermal_zone
      end
    end
    return false
  end

  def self.get_minimum_design_day_temperature(model)
    min_temp = 20

    model.getDesignDays.each do |design_day|
      max_temp = design_day.maximumDryBulbTemperature
      puts max_temp
      min_temp = max_temp if max_temp < min_temp
    end

    min_temp
  end

  def self.clean_up_model(model)
    model.getAirTerminalSingleDuctVAVReheats.each do |vav_box|
      outlet_node = vav_box.outletModelObject.get.to_Node
      if outlet_node.is_initialized
        subsequent_node = outlet_node.get.outletModelObject
        if subsequent_node.is_initialized
          port_list = subsequent_node.get.to_PortList
          unless port_list.is_initialized
            vav_box.removeFromLoop
            vav_box.remove
          end
        end
      end
    end
  end
end
