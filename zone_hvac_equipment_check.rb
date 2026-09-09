require 'openstudio'
require 'openstudio-standards'
include OpenStudio::Model

model = Model.new
zone = ThermalZone.new(model)

a1 = AirLoopHVAC.new(model)
at1 = AirTerminalSingleDuctConstantVolumeCooledBeam.new(model, model.alwaysOnDiscreteSchedule, CoilCoolingCooledBeam.new(model))
puts a1.addBranchForZone(zone, at1)

a2 = AirLoopHVAC.new(model)
at2 = AirTerminalSingleDuctConstantVolumeNoReheat.new(model, model.alwaysOnDiscreteSchedule)
# puts a2.multiAddBranchForZone(zone, at2)
puts a1.multiAddBranchForZone(zone, at2)

puts zone.equipment

puts zone.airLoopHVACs

# vt = OpenStudio::OSVersion::VersionTranslator.new
# model = vt.loadModel(OpenStudio::Path.new("C:\\Users\\eringold\\Revit System Analysis Reports\\REVIT-226703\\smalloffice\\smalloffice.osm")).get

# # build up first air loop
# a1 = AirLoopHVAC.new(model)
# oas1 = AirLoopHVACOutdoorAirSystem.new(model)
# oas1.addToNode(a1.supplyOutletNode)
# cc1 = CoilCoolingDXSingleSpeed.new(model)
# cc1.addToNode(a1.supplyOutletNode)
# hc1 = CoilHeatingDXSingleSpeed.new(model)
# hc1.addToNode(a1.supplyOutletNode)
# sp1 = SetpointManager