export PATH="/c/projects/openstudio/bin:/c/Ruby224-x64/ruby-2.2.4-x64-mingw32/bin:${PATH}"
echo $PATH
ruby -v

export RUBYLIB=/c/projects/openstudio/Ruby

rake test
