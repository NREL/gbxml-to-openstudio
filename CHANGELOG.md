# Changelog

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
