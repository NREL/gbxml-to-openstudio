

###### (Automatically generated documentation)

# Shadow Calculation

## Description
This measure sets the fields of the ShadowCalculation object, which is used to control some details of EnergyPlus’s solar, shadowing, and daylighting models.

## Modeler Description
The ShadowCalculation class does not have a public constructor because it is a unique ModelObject.

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Shading Calculation Method

**Name:** shading_calculation_method,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Shading Calculation Update Frequency Method

**Name:** shading_calculation_update_frequency_method,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Shading Calculation Update Frequency (days)
Shading Calculation Update Frequency Method = Periodic
**Name:** shading_calculation_update_frequency,
**Type:** Integer,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Maximum Figures in Shadow Overlap Calculations
Shading Calculation Method = PolygonClipping
**Name:** maximum_figures_in_shadow_overlap_calculations,
**Type:** Integer,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Polygon Clipping Algorithm
Shading Calculation Method = PolygonClipping
**Name:** polygon_clipping_algorithm,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Pixel Counting Resolution
Shading Calculation Method = PixelCounting
**Name:** pixel_counting_resolution,
**Type:** Integer,
**Units:** ,
**Required:** false,
**Model Dependent:** false

### Sky Diffuse Modeling Algorithm

**Name:** sky_diffuse_modeling_algorithm,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false




