

###### (Automatically generated documentation)

# ChangeBuildingLocation

## Description


## Modeler Description


## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Weather File Name
Name of the weather file to change to. This is the filename with the extension (e.g. NewWeather.epw). Optionally this can inclucde the full file path, but for most use cases should just be file name.
**Name:** weather_file_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false




### Climate Zone.

**Name:** climate_zone,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false


**Choice Display Names** ["Lookup From Stat File", "ASHRAE 169-2013-1A", "ASHRAE 169-2013-1B", "ASHRAE 169-2013-2A", "ASHRAE 169-2013-2B", "ASHRAE 169-2013-3A", "ASHRAE 169-2013-3B", "ASHRAE 169-2013-3C", "ASHRAE 169-2013-4A", "ASHRAE 169-2013-4B", "ASHRAE 169-2013-4C", "ASHRAE 169-2013-5A", "ASHRAE 169-2013-5B", "ASHRAE 169-2013-5C", "ASHRAE 169-2013-6A", "ASHRAE 169-2013-6B", "ASHRAE 169-2013-7A", "ASHRAE 169-2013-8A", "CEC T24-CEC1", "CEC T24-CEC2", "CEC T24-CEC3", "CEC T24-CEC4", "CEC T24-CEC5", "CEC T24-CEC6", "CEC T24-CEC7", "CEC T24-CEC8", "CEC T24-CEC9", "CEC T24-CEC10", "CEC T24-CEC11", "CEC T24-CEC12", "CEC T24-CEC13", "CEC T24-CEC14", "CEC T24-CEC15", "CEC T24-CEC16"]



### Set Calendar Year
This will impact the day of the week the simulation starts on. An input value of 0 will leave the year un-altered
**Name:** set_year,
**Type:** Integer,
**Units:** ,
**Required:** true,
**Model Dependent:** false




### Use Upstream Argument Values
When true this will look for arguments or registerValues in upstream measures that match arguments from this measure, and will use the value from the upstream measure in place of what is entered for this measure.
**Name:** use_upstream_args,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false




### Find and replace option from existing weather file name.
This will override what is entered in weather file name or from upstream measures, unless Do Nothing is selected.
**Name:** epw_gsub,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false


**Choice Display Names** ["Do Nothing", "TMY3,AMY", "AMY,TMY3"]






