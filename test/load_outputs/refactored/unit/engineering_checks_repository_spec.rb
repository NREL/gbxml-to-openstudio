﻿require_relative '../test_helper'

describe EPlusOut::Repositories::EngineeringChecksRepository do
  describe "#build_query" do
    it "builds the correct query" do
      expected_query = "SELECT Value FROM TabularDataWithStrings WHERE TableName = 'Engineering Checks for heating' AND UPPER(ReportForString) = 'TEST'  ORDER BY RowName ASC"

      repository = EPlusOut::Repositories::EngineeringChecksRepository.new(nil, nil)

      result = repository.build_query("test", "heating")

      assert_equal result, expected_query
    end
  end

  describe "#find_by_name_and_conditioning" do
    it "returns nil when invalid query" do
      sql_file_mock = MiniTest::Mock.new
      mapper_mock = MiniTest::Mock.new
      component_query = ""

      repository = EPlusOut::Repositories::EngineeringChecksRepository.new(sql_file_mock, mapper_mock)
      sql_file_mock.expect :execAndReturnVectorOfString, nil, [component_query]

      repository.stub :build_query, component_query do
        assert_nil repository.find_by_name_and_conditioning("test", "Cooling")
        sql_file_mock.verify
      end
    end

    it "calls the mapper if a result is returned" do
      sql_file_mock = MiniTest::Mock.new
      mapper_mock = MiniTest::Mock.new
      component_query = ""
      query_result = [0, 1]

      repository = EPlusOut::Repositories::EngineeringChecksRepository.new(sql_file_mock, mapper_mock)
      sql_file_mock.expect :execAndReturnVectorOfString, query_result, [component_query]
      mapper_mock.expect :call, nil, [query_result]

      repository.stub :build_query, component_query do
        assert_nil repository.find_by_name_and_conditioning("test", "Cooling")
        sql_file_mock.verify
        mapper_mock.verify
      end
    end
  end
end