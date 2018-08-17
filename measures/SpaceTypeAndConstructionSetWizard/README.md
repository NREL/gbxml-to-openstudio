

###### (Automatically generated documentation)

# Space Type and Construction Set Wizard

## Description
Create space types and or construction sets for the requested building type, climate zone, and target.

## Modeler Description
The data for this measure comes from the openstudio-standards Ruby Gem. They are no longer created from the same JSON file that was used to make the OpenStudio templates. Optionally this will also set the building default space type and construction set.

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Building Type.

**Name:** building_type,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Template.

**Name:** template,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Climate Zone.

**Name:** climate_zone,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Create Space Types?

**Name:** create_space_types,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Create Construction Set?

**Name:** create_construction_set,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Set Building Defaults Using New Objects?

**Name:** set_building_defaults,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false




