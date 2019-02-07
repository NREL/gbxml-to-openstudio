require_relative '../minitest_helper'

class TestDay < MiniTest::Test

  def test_from_xml_populated
    xml = <<EOF
    <Day dayScheduleIdRef="aim0156" dayType="All" />
EOF

    document = REXML::Document.new(xml)
    xml_day = GBXML::Day.from_xml(document.get_elements('Day')[0])
    memory_day = GBXML::Day.new
    memory_day.day_schedule_id_ref = "aim0156"
    memory_day.day_type = "All"

    assert(memory_day == xml_day)
  end
end