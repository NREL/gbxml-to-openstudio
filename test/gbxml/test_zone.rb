require_relative '../minitest_helper'

class TestZone < MiniTest::Test

  def test_from_xml_populated()
    xml = <<EOF
  <Zone id="aim34960">
    <OAFlowPerPerson unit="CFM">15</OAFlowPerPerson>
    <DesignHeatT unit="F">70</DesignHeatT>
    <DesignCoolT unit="F">74</DesignCoolT>
    <ZoneHVACEquipmentId zoneHVACEquipmentIdRef="aim34686" />
    <Name>VAV-1-24</Name>
    <CADObjectId>391710</CADObjectId>
  </Zone>
EOF
  end

end