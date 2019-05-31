# Changelog

## [0.1.4] - 2019-05-29
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
