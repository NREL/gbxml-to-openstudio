﻿require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require_relative '../../../measures/loads_output_report/eplusout/eplusout'