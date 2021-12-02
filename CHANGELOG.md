# Changelog

## [1.0.4] - 2021-12-01
### Changed
 - gbXML import performance improvements
 - Minor changes to support OpenStudio v3.0.0

## [1.0.3] - 2021-02-01
### Added
 - Charts for the zone and system load summary PDF
 - Updated Design Psychrometrics PDF
 
### Fixed
 - Alignment for long words in the summary content
 - Issue preventing the PDF from opening in Adobe

## [1.0.2] - 2021-01-21
### Changed
 - Updated the report PDF view for the tables. Charts don't render yet.
 - Removed on hover tooltip from the dropdown selector
 - Reintroduced the print button
 
### Fixed
 - Various localization fixes
   - When no zones/systems/coils found
   - Acronyms are now translated
   - Unit system dropdown is now localized
   - Styling that caused the left side of the report to be cut off when using a narrow window
   - Pie chart labels fixed to support 6 sig. fig.

## [1.0.1] - 2020-12-15
### Changed
 - The HTML view design has been updated to the specification
 - The locale button has been removed
 - The print button has been removed
 - Units button now states "units" after the unit system.
 
### Fixed
 - A fix for E+ reporting OA as a decimal has been implemented
 - Localization for some additional words have been added.
 
## [1.0.0] - 2020-10-08
### Fixed
 - Various unit conversions including temperature and power
 - Eplusout now covers edge cases where E+ stores % incorrectly.

## [0.1.20] - 2020-09-11
### Added
 - Conversion layer to work with E+ simulations run in IP or SI
 - Reading the configuration file from the simulation root
 - Debug mode to write the data out as a JSON file

### Fixed
 - Fixed Psychrometric map from rendering mixed unit systems. Defaults to IP now even if Revit units are selected.

## [0.1.19] - 2020-07-08
### Added
 - Updated the Design Psychometrics to show the state point of air in the table
 - Added a psychrometric chart as a visualization for Design Psychrometrics
 - Added localization to the labels
 - Added client-side printing although issues with localization still need to be addressed

## [0.2.0] - 2019-10-31
### Fixed
 - Performance issues related to the annual and weekly schedules being inferred from the Building Type

## [0.1.9] - 2019-10-31
### Fixed
 - Activity Schedules regression
 
## [0.1.8] - 2019-09-13
### Added
 - Inference of annual and weekly schedules from the Building Type
 
### Changed
 - Improved absorptance property import to prevent issue related to material present on more than one construction outer layer.

## [0.1.6] - 2019-06-07
### Added
 - Merged OpenStudio Results and eplustbl.htm report
 
### Changed
 - Both sizing and annual reports write to openstudio_results_report.html

## [0.1.5] - 2019-06-04
### Changed
 - Removed the "OpenStudio Results" header from the annual simulation report
 - "OpenStudio Results" changed to "Annual Simulation Report" in the html title.

## [0.1.4] - 2019-05-31
### Added
 - Global sizing factors added to set_simulation_control measure with default at 1.0 for heating and cooling
### Changed
 - Changed the OSW names to "Annual Building Energy Simulation.osw" and "HVAC Systems Loads and Sizing.osw"
 - Updated sizing schedules to be all off for heating and all on for cooling
 - Weather file measure now grabs the most stringent percentiles available and falls back to less stringent if unavailable
 - Infiltration set on a per unit of exterior wall area rather than all exterior area
### Fixed
 - IP units electricity consumption issue on the openstudio_results html report.
### Removed
 - Redundant code
 
## [0.1.2] - 2019-05-22
### Added
 - Setpoint Manager at 4C on the preheat coil to temper the incoming outdoor air stream
 - Zone equipment respond to the draw ventilation parameter
 - Support for material solar absorptance
 - eplustbl.html now respond to the output units desired by the gbXML file
 - Sensible heat ratio of people load is translated correctly
### Changed
 - Adjusted zone equipment load priority so that air terminals on a DOAS are lowest ensuring they only respond to ventilation.
 - Zone equipment that provide outdoor air directly now have a constant volume fan so ventilation is always met
 - Made the chilled water a variable speed setup
 - VAV boxes on a DOAS control for outdoor air to enable DCV
 - Set the solar distribution algorithm to 'FullExterior' from 'Minimal Shadowing'
### Fixed
 - Resolved issue with chilled water supplying at the loop temperature delta rather than design
### Removed
 - Removed the loads_out.json report

## [0.1.1] - 2019-05-10
### Added
- Added the ability for an Air System to operate as a DOAS
- Zone sizing temperatures are now determined by the type of equipment serving that zone
- Made zone equipment aware of their zones to allow for two-way data traversal

### Changed
- Altered the zone sizing objects to account for the effect of a DOAS
- Altered the System sizing objects to account for the effect of a DOAS
- Changed the zone HVAC Equipment design supply temperatures
- Adjusted the structure of the HVAC measure to be more consistent across systems
- Added a fluid cooler rather than cooling tower to condenser loops to be more representative for WSHP systems when present
- Adjusted the design temperatures of most HVAC systems to be more representative of typical design
- Set the location/weather file at the top of the workflow to allow design days to set the incoming air temperature for sizing of preheat coils
- Moved the preheat coil into the incoming outdoor air stream to allow E+ to size it more accurately
- Allowed chilled water loops to size for radiant-like temperatures when no lower temperature equipment are on the loop
- Removed fan power from passive chilled beams and radiant panels as a FPFC approximation is being used
- Added post-build step to decouple object creation from connecting nodes

### Fixed
- Fixed FPFC bug in the reporting that caused the simulation to fail
