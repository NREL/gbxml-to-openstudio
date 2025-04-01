require 'fileutils'
require 'openstudio'
require 'parallel'

# constants
TEST_TYPE = ARGV[0]
TEST_SIZE = ARGV[1]
OS_VERSION = OpenStudio.openStudioVersion
DIRNAME = File.dirname(__FILE__)
FIXTURES_PATH = "#{DIRNAME}/fixtures"
OUTPUT_PATH = "#{DIRNAME}/integration/output/#{TEST_TYPE}/#{OS_VERSION}"
OSW_TEMPLATE = "#{DIRNAME}/integration/#{TEST_TYPE}.osw"

case TEST_SIZE
when 'large'
  # all files
  fixtures = Dir.children(FIXTURES_PATH)
when 'small'
  # files < 1000 KB
  fixtures = []
  Dir.children(FIXTURES_PATH).each { |f| fixtures << f if File.size("#{FIXTURES_PATH}/#{f}") <= 1000000 }
else
  raise "missing argument for 'large' or 'small'"
end

if Dir.exist?(OUTPUT_PATH)
  puts "removing directories in: #{OUTPUT_PATH}"
  FileUtils.rm_rf(OUTPUT_PATH)
end

puts "creating directories in: #{OUTPUT_PATH}"
osw = File.read("#{OSW_TEMPLATE}")
osw_jobs = []
fixtures.each do |f|
  output_dir = "#{OUTPUT_PATH}/#{f}"
  osw_path = "#{output_dir}/#{TEST_TYPE}.osw"
  FileUtils.mkdir_p(output_dir)
  File.write(osw_path, osw.gsub('GBXML_INPUT.xml', f))
  osw_jobs << "openstudio run -w \"#{osw_path}\""
end

Parallel.each(osw_jobs, in_threads: 11) do |job|
  start = Time.now
  osw = "#{job.gsub('openstudio run -w', '')}"
  puts osw
  system(job)
  stop = Time.now
  puts "#{osw}: #{(stop - start).to_i} s"
end
