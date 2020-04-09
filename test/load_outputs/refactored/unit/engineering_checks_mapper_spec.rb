﻿require_relative '../test_helper'

describe EPlusOut::Mappers::EngineeringChecksMapper do
  describe "#klass" do
    it "its class is of type EPlusOut::EngineeringChecks" do
      mapper = EPlusOut::Mappers::EngineeringChecksMapper.new
      assert_equal(mapper.klass, EPlusOut::EngineeringChecks)
    end
  end

  describe "param_map" do
    it "returns an Array" do
      mapper = EPlusOut::Mappers::EngineeringChecksMapper.new

      mapper.param_map.must_be_instance_of Array
    end
  end
end
