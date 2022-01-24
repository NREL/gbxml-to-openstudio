require 'bundler'
require 'rake/testtask'
Bundler.setup

# DLM: this is needed if we want to use standards and workflow gem from bundle Gemfile rather than embedded
# we can remove these variables before calling the CLI in minitest_helper.rb to use the embedded CLI
if ENV['BUNDLE_GEMFILE']
  if ENV['BUNDLE_PATH'].nil?
    ENV['BUNDLE_PATH'] = ENV['GEM_HOME']
  end
end

require 'rake'
require 'fileutils'

task default: 'test'

Rake::TestTask.new do |t|
  t.pattern = "test/gbxml_hvac_import/test*.rb"
end

desc 'Build Installer'
task :build_installer do
  require 'fileutils'

  root_dir = File.join(File.dirname(__FILE__))
  staging_dir = File.join(root_dir, 'installer_staging')
  os_install_dir = 'C:\openstudio-3.3.0'
  openstudio_cli = File.join(os_install_dir, 'bin', 'openstudio.exe')
  energyplus_dir = File.join(os_install_dir, 'EnergyPlus')

  unless File.exists?(os_install_dir)
    puts "#{os_install_dir} does not exist"
    exit 1
  end

  FileUtils.rm_rf(staging_dir) if File.exists?(staging_dir)
  FileUtils.mkdir_p(staging_dir)
  FileUtils.cp(File.join(root_dir, 'CHANGELOG.md'), File.join(staging_dir, 'CHANGELOG.md'))
  FileUtils.mkdir_p(File.join(staging_dir, 'bin'))
  FileUtils.cp(openstudio_cli, File.join(staging_dir, 'bin', 'openstudio.exe'))
  FileUtils.cp(File.join(os_install_dir, 'bin', 'concrt140.dll'), File.join(staging_dir, 'bin', 'concrt140.dll'))
  FileUtils.cp(File.join(os_install_dir, 'bin', 'msvcp140.dll'), File.join(staging_dir, 'bin', 'msvcp140.dll'))
  FileUtils.cp(File.join(os_install_dir, 'bin', 'msvcp140_1.dll'), File.join(staging_dir, 'bin', 'msvcp140_1.dll'))
  FileUtils.cp(File.join(os_install_dir, 'bin', 'msvcp140_2.dll'), File.join(staging_dir, 'bin', 'msvcp140_2.dll'))
  FileUtils.cp(File.join(os_install_dir, 'bin', 'msvcp140_codecvt_ids.dll'), File.join(staging_dir, 'bin', 'msvcp140_codecvt_ids.dll'))
  FileUtils.cp(File.join(os_install_dir, 'bin', 'vcruntime140.dll'), File.join(staging_dir, 'bin', 'vcruntime140.dll'))
  FileUtils.cp(File.join(os_install_dir, 'bin', 'vcruntime140_1.dll'), File.join(staging_dir, 'bin', 'vcruntime140_1.dll'))

  FileUtils.cp_r(energyplus_dir, File.join(staging_dir, 'EnergyPlus'))
  FileUtils.rm(File.join(staging_dir, 'EnergyPlus', 'energyplusapi.lib'))
  FileUtils.cp_r(File.join(root_dir, 'measures'), File.join(staging_dir, 'measures'))
  FileUtils.cp_r(File.join(root_dir, 'seeds'), File.join(staging_dir, 'seeds'))
  FileUtils.cp_r(File.join(root_dir, 'weather'), File.join(staging_dir, 'weather'))
  FileUtils.cp_r(File.join(root_dir, 'workflows'), File.join(staging_dir, 'workflows'))

  # TODO: update copyright on measures, see openstudio-measures repo for example
  # TODO: need to add a license and copyright to this repo, install those as well
  # TODO: run MSI creation script
  # TODO: sign and version MSI
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