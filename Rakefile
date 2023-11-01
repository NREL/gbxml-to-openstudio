require 'bundler'
require 'fileutils'
require 'rake/testtask'

# DLM: this is needed if we want to use standards and workflow gem from bundle Gemfile rather than embedded
# we can remove these variables before calling the CLI in minitest_helper.rb to use the embedded CLI
if ENV['BUNDLE_GEMFILE']
  if ENV['BUNDLE_PATH'].nil?
    ENV['BUNDLE_PATH'] = ENV['GEM_HOME']
  end
end

# constants
ROOT_DIR = File.join(File.dirname(__FILE__))
PRESIGN_DIR = 'build'
OS_DIR = 'C:\openstudio-3.6.0\bin'
EP_DIR = 'C:\EnergyPlusV23-1-0-revit'
PYTHON = false

POSTSIGN_DIR = "#{PRESIGN_DIR}.signed/#{PRESIGN_DIR}"
EP_FILES_UNSIGNED = [
  'Energy+.idd',
  'Energy+.schema.epJSON',
  'energyplusapi.lib'
]
OSW_FILES = [
  'Annual Building Energy Simulation.osw',
  'HVAC Systems Loads and Sizing.osw'
]

Bundler.setup

task default: 'test'

Rake::TestTask.new do |t|
  t.pattern = "test/gbxml_hvac_import/test*.rb"
end

desc 'pre sign'
task :presign do

  unless File.exists?(OS_DIR)
    puts "#{OS_DIR} does not exist"
    exit 1
  end

  # dirs
  FileUtils.rm_rf(PRESIGN_DIR) if File.exists?(PRESIGN_DIR)
  FileUtils.mkdir_p(PRESIGN_DIR)
  FileUtils.mkdir_p(File.join(PRESIGN_DIR, 'bin'))
  FileUtils.mkdir_p(File.join(PRESIGN_DIR, 'EnergyPlus'))

  # openstudio signed files
  FileUtils.cp(File.join(OS_DIR, 'openstudio.exe'), File.join(PRESIGN_DIR, 'bin', 'openstudio.exe'))
  (Dir.glob('*.dll', base: OS_DIR)).each { |f| FileUtils.cp(File.join(OS_DIR, f), File.join(PRESIGN_DIR, 'bin', f)) }

  # energyplus signed files
  (%w[energyplus.exe ExpandObjects.exe] +
    Dir.glob('*.dll', base: EP_DIR)
  ).each { |f| FileUtils.cp(File.join(EP_DIR, f), File.join(PRESIGN_DIR, 'EnergyPlus', f)) }
  # TODO the python38.dll isn't currently included in the custom EnergyPlus build
  FileUtils.rm(File.join(PRESIGN_DIR, 'EnergyPlus', 'python38.dll')) unless PYTHON

  # TODO: update copyright on measures, see openstudio-measures repo for example
  # TODO: need to add a license and copyright to this repo, install those as well
  # TODO: run MSI creation script
  # TODO: sign and version MSI

end

desc 'post sign'
task :postsign do

  # dirs
  FileUtils.mkdir_p(File.join(POSTSIGN_DIR, 'gbxmls'))
  FileUtils.mkdir_p(File.join(POSTSIGN_DIR, 'workflows'))

  # copy unsigned openstudio and energyplus files
  FileUtils.cp(File.join(OS_DIR, 'openstudiolib.lib'), File.join(POSTSIGN_DIR, 'bin', 'openstudiolib.lib'))
  EP_FILES_UNSIGNED.each { |f| FileUtils.cp(File.join(EP_DIR, f), File.join(POSTSIGN_DIR, 'EnergyPlus', f)) }
  FileUtils.cp_r(File.join(EP_DIR, 'pyenergyplus'), File.join(POSTSIGN_DIR, 'EnergyPlus', 'pyenergyplus'))
  FileUtils.cp_r(File.join(EP_DIR, 'python_standard_lib'), File.join(POSTSIGN_DIR, 'EnergyPlus', 'python_standard_lib')) if PYTHON

  # copy other files
  FileUtils.cp(File.join(ROOT_DIR, 'CHANGELOG.md'), File.join(POSTSIGN_DIR, 'CHANGELOG.md'))
  FileUtils.cp(File.join(ROOT_DIR, 'gbxmls', 'analysis.xml'), File.join(POSTSIGN_DIR, 'gbxmls', 'analysis.xml'))
  FileUtils.cp_r(File.join(ROOT_DIR, 'measures'), File.join(POSTSIGN_DIR, 'measures'))
  FileUtils.cp_r(File.join(ROOT_DIR, 'seeds'), File.join(POSTSIGN_DIR, 'seeds'))
  FileUtils.cp_r(File.join(ROOT_DIR, 'weather'), File.join(POSTSIGN_DIR, 'weather'))
  OSW_FILES.each { |f| FileUtils.cp_r(File.join(ROOT_DIR, 'workflows', f), File.join(POSTSIGN_DIR, 'workflows', f)) }

end

desc 'Update measure.xml files in measure directory'
task :update_measure_xmls do
  require 'fileutils'
  require 'openstudio'

  puts 'Updating measure.xml for all measures in the repository.'

  # get measures in repo
  measures_directory = File.join(File.dirname(__FILE__), 'measures')

  # run OpenStudio command line measure update for measures directory
  cli_path = OpenStudio.getOpenStudioCLI
  cmd = "\"#{cli_path}\" measure --update_all \"#{measures_directory}\""
  system(cmd)

  puts "Updated measure.xml files for measures in measure directory (#{measures_directory})"
end