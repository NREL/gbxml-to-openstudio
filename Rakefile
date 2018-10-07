require 'bundler'
require 'rake/testtask'
Bundler.setup

require 'rake'
require 'erb'
require 'fileutils'
require 'pathname'
require 'securerandom'

task default: 'test'

desc 'Run the tests'
task :test do
end

Rake::TestTask.new do |t|
  t.pattern = "test/*/test*.rb"
end

def clean_id(id)
  id = '_' + id
  return id.gsub(' ', '').gsub('-', '').gsub('+', '')
end

def get_dir_id(f, staging_dir, dir_id_map)
  if f == staging_dir
    return 'APPDIR'
  end
  
  basename = File.basename(f)
  dif_id = clean_id(basename + '_Dir')
  
  if dir_id_map[dif_id].nil?
    dir_id_map[dif_id] = f
  else
    i = 0
    while dir_id_map[dif_id] && dir_id_map[dif_id] != f
      i += 1
      dif_id = clean_id(basename + "_#{i}_Dir")
    end
    dir_id_map[dif_id] = f
  end
  
  return dif_id
end

def get_file_id(f, file_id_map)
  
  basename = File.basename(f)
  file_id = clean_id(basename)
  
  if file_id_map[file_id].nil?
    file_id_map[file_id] = f
  else
    i = 0
    while file_id_map[file_id] && file_id_map[file_id] != f
      i += 1
      file_id = clean_id(basename + "_#{i}")
    end
    file_id_map[file_id] = f
  end
  
  return file_id
end

def clean_short_name(s)
  return s.upcase.gsub(' ', '').gsub('-', '').gsub('+', '').gsub('.', '')
end

$MSI_names = {}
def get_msiname(s)
  if s.size <= 8
    return s
  end
  
  short_name = "#{clean_short_name(s)[0...6]}~1"
  
  if $MSI_names[short_name].nil?
    $MSI_names[short_name] = s
  else
    i = 1
    while $MSI_names[short_name] && $MSI_names[short_name] != s
      i += 1
      short_name = "#{clean_short_name(s)[0...6]}~#{i}"
    end
    $MSI_names[short_name] = s
  end
  
  if short_name.size == 9
    #puts "old short_name = #{short_name}"
    short_name = short_name[0...5] + short_name[6...9]
    #puts "new short_name = #{short_name}"
  elsif short_name.size > 9
    raise "Shortname for #{s} is greater than 9 characters at #{short_name}"
  end
  
  return "#{short_name}|#{s}"
end

def get_dir(f, staging_dir, dir_id_map)
  # <ROW Directory="APPDIR" Directory_Parent="TARGETDIR" DefaultDir="APPDIR:." IsPseudoRoot="1"/>
  if f == staging_dir
    return {:Directory => 'APPDIR', :Directory_Parent => 'TARGETDIR', :DefaultDir => 'APPDIR:.', :IsPseudoRoot => '1'}
  end
  
  # <ROW Directory="gbxml_hvac_import_Dir" Directory_Parent="measures_Dir" DefaultDir="GBXML_~1|gbxml_hvac_import"/>
  # <ROW Directory="docs_1_Dir" Directory_Parent="gbxml_hvac_import_Dir" DefaultDir="docs"/>
  basename = File.basename(f)
  dir_id = get_dir_id(f, staging_dir, dir_id_map)
  parent_dir_id = get_dir_id(File.dirname(f), staging_dir, dir_id_map)
  
  return {:Directory => dir_id, :Directory_Parent => parent_dir_id, :DefaultDir => get_msiname(basename), :IsPseudoRoot => nil}
end

def get_component(f, staging_dir, dir_id_map, file_id_map)
  #<ROW Component="apimswincoredebugl110.dll" ComponentId="{9919EFA2-EAF7-4D12-9C2F-8F0321D160CE}" Directory_="EnergyPlus_Dir" Attributes="256" KeyPath="apimswincoredebugl110.dll"/>
  
  file_id = get_file_id(f, file_id_map)
  
  # TODO: get this from existing aip
  component_id = "{#{SecureRandom.uuid.to_s}}"
  
  dir_id = get_dir_id(File.dirname(f), staging_dir, dir_id_map)
  
  extname = File.extname(f)
  attributes = '0'
  if extname == '.exe' || extname == '.dll'
    attributes = '256'
  end
  
  return {:Component => file_id, :ComponentId => component_id, :Directory_ => dir_id, :Attributes => attributes, :KeyPath => file_id, :Type => attributes}
end


def get_file(f, staging_dir, dir_id_map, file_id_map)
  #<ROW File="EnableIdealAirLoadsForAllZones_Test.rb" Component_="EnableIdealAirLoadsForAllZones_Test.rb" FileName="ENABLE~1.RB|EnableIdealAirLoadsForAllZones_Test.rb" Attributes="0" SourcePath="installer_staging\measures\EnableIdealAirLoadsForAllZones\tests\EnableIdealAirLoadsForAllZones_Test.rb" SelfReg="false" NextFile="IdealAir_TestModel.osm"/>

  file_id = get_file_id(f, file_id_map)
  basename = File.basename(f)
  
  extname = File.extname(f)
  attributes = '0'
  if extname == '.exe' || extname == '.dll'
    attributes = '256'
  end

  relative = Pathname.new(f).relative_path_from(Pathname.new(staging_dir))
  
  return {:File => file_id, :Component_ => file_id, :FileName => get_msiname(basename), :Attributes => attributes, :SourcePath => relative, :SelfReg => 'false', :NextFile =>nil}
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

  FileUtils.rm_rf staging_dir if File.exists?(staging_dir)
  FileUtils.mkdir_p(staging_dir)
  FileUtils.mkdir_p(File.join(staging_dir, 'bin'))
  FileUtils.cp(openstudio_cli, File.join(staging_dir, 'bin', 'openstudio.exe'))
  FileUtils.cp_r(energyplus_dir, File.join(staging_dir, 'EnergyPlus'))
  FileUtils.cp_r(File.join(root_dir, 'measures'), File.join(staging_dir, 'measures'))
  FileUtils.cp_r(File.join(root_dir, 'seeds'), File.join(staging_dir, 'seeds'))
  FileUtils.cp_r(File.join(root_dir, 'weather'), File.join(staging_dir, 'weather'))
  FileUtils.cp_r(File.join(root_dir, 'workflows'), File.join(staging_dir, 'workflows'))
  
  # TODO: need to add a license and copyright to this repo, install those as well

  template_in = File.read('gbxml-to-openstudio.aip.in')
  
  # get listing of all the files
  dirs = []
  components = []
  files = []
  dir_id_map = {}
  file_id_map = {}
  
  dirs << get_dir(staging_dir, staging_dir, dir_id_map)
  components << {:Component => "ProductInformation", :ComponentId => "{8845EE96-7C3F-4EA1-BAB7-B156FF6BC18E}", :Directory_ => "APPDIR", :Attributes => "260", :KeyPath=> "Version"}
  
  Dir.glob(staging_dir + '/**/*').each do |f|
    if File.directory?(f)
      dirs << get_dir(f, staging_dir, dir_id_map)
    else
      components << get_component(f, staging_dir, dir_id_map, file_id_map)
      files << get_file(f, staging_dir, dir_id_map, file_id_map)
    end
  end
  
  dirs_xml = ""
  dirs.each do |dir|
    if dir[:IsPseudoRoot]
      dirs_xml += "<ROW Directory=\"#{dir[:Directory]}\" Directory_Parent=\"#{dir[:Directory_Parent]}\" DefaultDir=\"#{dir[:DefaultDir]}\" IsPseudoRoot=\"#{dir[:IsPseudoRoot]}\"/>\n    "
    else
      dirs_xml += "<ROW Directory=\"#{dir[:Directory]}\" Directory_Parent=\"#{dir[:Directory_Parent]}\" DefaultDir=\"#{dir[:DefaultDir]}\"/>\n    "
    end
  end
  dirs_xml.strip!
  
  components_xml = ""
  components_list = "ProductInformation "
  components.each do |component|
    components_list += "#{component[:Component]} "
    components_xml += "<ROW Component=\"#{component[:Component]}\" ComponentId=\"#{component[:ComponentId]}\" Directory_=\"#{component[:Directory_]}\" Attributes=\"#{component[:Attributes]}\" KeyPath=\"#{component[:KeyPath]}\" Type=\"#{component[:Type]}\"/>\n    "
  end
  components_list.strip!
  components_xml.strip!
  
  files_xml = ""
  files_list = ""
  files.each do |file|
    files_list += "#{file[:File]} "
    files_xml += "<ROW File=\"#{file[:File]}\" Component_=\"#{file[:Component_]}\" FileName=\"#{file[:FileName]}\" Attributes=\"#{file[:Attributes]}\" SourcePath=\"#{file[:SourcePath]}\" SelfReg=\"#{file[:SelfReg]}\" NextFile=\"#{file[:NextFile]}\"/>\n    "
  end
  files_list.strip!
  files_xml.strip!
  
  template = ERB.new(template_in)
  File.open('gbxml-to-openstudio.out.aip', 'w') do |f|
    f << template.result(binding)
  end
  
  # TODO: run MSI creation script
  # https://www.advancedinstaller.com/user-guide/command-line.html
  
  # TODO: sign and version MSI
end

