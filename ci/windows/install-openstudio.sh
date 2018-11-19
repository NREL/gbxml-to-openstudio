curl -SLO --insecure https://openstudio-builds.s3.amazonaws.com/2.7.1/OpenStudio-2.7.1.b8d47b8b9d-Windows.exe
ls -al

# todo use argument instead of hardcoded /d/a/1/s/ path prefix.  this should come through "arguments" from azure-pipelines.yml definition,
./OpenStudio-2.7.1.b8d47b8b9d-Windows.exe --script /d/a/1/s/ci/windows/install.qs
mkdir -p /c/projects
mv /c/openstudio-2.7.1 /c/projects/openstudio
ls /c/projects
ls /c/projects/openstudio
#we will set PATH before we actually run tests
#echo $PATH
#export PATH="/c/projects/openstudio/bin;${PATH}"
#echo $PATH