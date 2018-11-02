require 'bundler'
require 'rake/testtask'
Bundler.setup

require 'rake'
require 'fileutils'

task default: 'test'

desc 'Run the tests'
task :test do
end

Rake::TestTask.new do |t|
  t.pattern = "test/*/test*.rb"
end

desc 'Build Installer'
task :build_installer do
  require 'fileutils'

  root_dir = File.join(File.dirname(__FILE__))
  staging_dir = File.join(root_dir, 'installer_staging')
  os_install_dir = 'C:\openstudio-2.6.0'
  openstudio_cli = File.join(os_install_dir, 'bin', 'openstudio.exe')
  energyplus_dir = File.join(os_install_dir, 'EnergyPlus')
  
  if !File.exists?(os_install_dir)
    puts "#{os_install_dir} does not exist"
    exit 1
  end
  
  # TODO: update copyright on measures, see openstudio-measures repo for example
  
  # TODO: run update measure task, see openstudio-measures repo for example

  FileUtils.rm_rf(staging_dir) if File.exists?(staging_dir)
  FileUtils.mkdir_p(staging_dir)
  FileUtils.mkdir_p(File.join(staging_dir, 'bin'))
  FileUtils.cp(openstudio_cli, File.join(staging_dir, 'bin', 'openstudio.exe'))
  FileUtils.cp_r(energyplus_dir, File.join(staging_dir, 'EnergyPlus'))
  FileUtils.cp_r(File.join(root_dir, 'measures'), File.join(staging_dir, 'measures'))
  FileUtils.cp_r(File.join(root_dir, 'seeds'), File.join(staging_dir, 'seeds'))
  FileUtils.cp_r(File.join(root_dir, 'weather'), File.join(staging_dir, 'weather'))
  FileUtils.cp_r(File.join(root_dir, 'workflows'), File.join(staging_dir, 'workflows'))
  
  # TODO: need to add a license and copyright to this repo, install those as well

  # TODO: run MSI creation script
  
  # TODO: sign and version MSI
end

