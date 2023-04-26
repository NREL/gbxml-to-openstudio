# gbXML to OpenStudio

This repository is intended to develop code that uses one or more advanced gbXML import measures to take gbXML to OSM translation beyond what is covered by GbXMLReverseTranslator in the OpenStudio C++ code.

## Directories

- `gbxmls` - example gbXML files, and complex models for regression testing
- `measures` - existing and new measures used to translate and test gbXML to OSM translation
- `seeds` - contains seed models used by one or more OSW workflows
- `weather` - contains weather files used by OSW workflows
- `workflows` - OSW workflow files that using the OpenStudio CLI run the gbXML to OSM translation workflow measures, forward translate OSM to IDF, and run EnergyPlus

## Configure Development Environment
1. Install the custom [EnergyPlus v22.1.0 build](https://openstudio-cli-4r.s3.amazonaws.com/EnergyPlus/EnergyPlus-22.1.0-ed759b17ee-Windows-x86_64.exe) that was compiled with `LINK_WITH_PYTHON` disabled, so no Python binary blobs or Python stdlib files are included
   1. Change the default install location so that it can be installed alongside the official v22.1.0 release if necessary (e.g. `C:\EnergyPlusV22-1-0-no-python`)
2. Install [OpenStudio v3.4.0](https://github.com/NREL/OpenStudio/releases/download/v3.4.0/OpenStudio-3.4.0+4bd816f785-Windows.exe)
3. Install [Ruby v2.7 for Windows](https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.8-1/rubyinstaller-2.7.8-1-x64.exe) (devkit shouldn't be necessary)
   1. Open a command prompt in the `gbxml-to-openstudio` directory
   2. Run `gem install bundler`
   3. Run `bundler install`
4. Install [7-Zip](https://www.7-zip.org/download.html)
5. Install the latest [Advanced Installer](https://www.advancedinstaller.com/download.html)

## Building Signed Installers
1. Pull the latest code
2. Update `CHANGELOG.md` to reflect changes included in the new release
3. If a previous `installer_staging` directory exists move it to `installer_stating.old`
4. Run `rake build_installer` (`bundler install` may be necessary as well if the gem dependencies have changed)
5. Zip the `installer_staging` directory using 7-Zip, and drag the resulting zip file to the `code-signing-client.exe` executable. 7-Zip is necessary because Windows is unable to compress files with unicode names
6. Once `installer_staging.signed.zip` has finished downloading simply extract the contents back into the `installer_staging` directory, replacing the original files
7. Diff the `installer_stating.old` and `installer_staging` directories
    1. If any files were *added* they must be manually dragged into the Advanced Installer file tree
    2. If any files were _removed_ they must be manually deleted from the Advanced Installer file tree
8. In _Advanced Installer_, with the `Product Details` tab active, increment the patch version (e.g. `1.1.5` -> `1.1.6`) and hit _Save_
    1. When prompted to generate a new product code click `Generate new`, and save again
9. In _Advanced Installer_, with the `Product Details` tab active, click `Build` in the ribbon
10. Once the build has successfully completed, browse to the `OpenStudio CLI For Revit 202X-SetupFiles/` directory, and drag the newly created msi to the `code-signing-client.exe` executable
11. After the signed msi has been downloaded delete the original and remove the `.signed` suffix from the filename
12. Upload the signed msi installer to the `openstudio-cli-4r` S3 bucket. Append the filename to `https://openstudio-cli-4r.s3.amazonaws.com/` to download
13. Delete the `installer_staging.old` directory if it was created
14. Commit the `*.aip` and `CHANGELOG.md` file changes
15. Create a git tag on the new commit matching the updated release version
