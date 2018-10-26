# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class CleanNames < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'CleanNames'
  end

  # human readable description
  def description
    return 'Creates object names which will not cause issues on translation to EnergyPlus'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Any names which are ok in EnergyPlus will be retained.  Otherwise, a suitable name will be chosen.  A mapping file, name_mapping_report.csv, will be written out with columns uuid, type, old_name, new_name, CADObjectId.  Additionally,the OSM before renaming will be written out as oldname_report.osm.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end
    
    # save the model before changing names
    model.save('oldname_report.osm', true)
    
    num_renamed = 0
    name_mapping = ''
    model.modelObjects.each do |object|
      name = object.name
      next if name.empty?
      
      # names in OSM are UTF-8 encoded
      old_name = name.get.force_encoding(Encoding::UTF_8)
      
      next if old_name.empty?
      
      uuid = object.handle
      type = object.iddObject.name
      
      new_name = ''
      if !old_name.ascii_only? || /[,!]/.match(old_name)
        name = object.createName(true)
        num_renamed += 1
        if name.empty?
          runner.registerError("Failed to rename #{object.briefDescription}.")
        else
          new_name = name.get
        end
      else 
        new_name = old_name
      end
      
      cadObjectId = ''
      begin
        if object.hasAdditionalProperties
          additionalProperties = object.additionalProperties
          if additionalProperties.hasFeature("CADObjectId")
            tmp = additionalProperties.getFeatureAsString("CADObjectId")
            if tmp.empty?
              cadObjectId = tmp.get
            end
          end
        end
      rescue
      
      end
      
      name_mapping += "\"#{uuid}\", \"#{type}\", \"#{old_name}\", \"#{new_name}\", \"#{cadObjectId}\"\n"
    end
    
    File.open('name_mapping_report.csv', 'w') do |file|
      file << name_mapping
    end

    # report final condition of model
    runner.registerFinalCondition("#{num_renamed} were renamed.")

    return true
  end
end

# register the measure to be used by the application
CleanNames.new.registerWithApplication
