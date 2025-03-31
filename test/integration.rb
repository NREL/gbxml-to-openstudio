require 'fileutils'

path_datapoints = "build"

# loop through resource files
jobs = []
results_directories = Dir.glob("#{path_datapoints}/*")
results_directories.each do |directory|
  puts "running #{directory}"
  test_dir = "#{directory}/data_point.osw"
  string = "openstudio run -w '#{test_dir}'"
  if not File.file?(test_dir)
    puts "data_point.osw not found for #{directory}"
    next
  end

  # system(string)
  jobs << string

end

# todo - process doesn't break for failed simulations, but some failures to break it, such as invalid argument values for measures.

# run the jobs
# if gem parallel isn't installed then comment out this could and use system(string) to run one job at a time
require 'parallel'
num_parallel = 11 # 6 on mac 11 on pc
Parallel.each(jobs, in_threads: num_parallel) do |job|
  puts job
  system(job)
end