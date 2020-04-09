﻿require_relative '../test_helper'

describe EPlusOut::Mappers::Mapper do
  describe "#klass" do
    it "must raise a NotImplementedError" do
      mapper = EPlusOut::Mappers::Mapper.new
      assert_raises NotImplementedError do
        mapper.klass
      end
    end
  end

  describe "#param_map" do
    it "must raise a NotImplementedError" do
      mapper = EPlusOut::Mappers::Mapper.new
      assert_raises NotImplementedError do
        mapper.param_map
      end
    end
  end

  describe "#call" do
    before do
      class Foo
        attr_accessor :bar, :baz
      end

      class FooMapper < EPlusOut::Mappers::Mapper
        PARAM_MAP = [
            {:index => 0, :name => :bar, :type => 'string'},
            {:index => 1, :name => :baz, :type => 'double'}
        ]

        def klass
          Foo
        end

        def param_map
          PARAM_MAP
        end
      end
    end

    it "maps data to a new instance of the klass" do
      mapper = FooMapper.new
      result = mapper.call(["A", "1"])

      result.must_be_instance_of Foo
      result.bar.must_equal "A"
      result.baz.must_equal 1
    end
  end

  describe ".cast_type" do
    it "converts a string number to a float" do
      EPlusOut::Mappers::Mapper.cast_type("1", "double").must_be_instance_of Float
    end
  end
end
