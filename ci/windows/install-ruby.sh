# Ruby downloaded / extracted in prior steps
# mv /c/Ruby224-x64/ruby-2.2.4-x64-mingw32 /c/Ruby224-x64
export PATH="/c/projects/openstudio/bin:/c/Ruby224-x64/ruby-2.2.4-x64-mingw32/bin:${PATH}"
echo $PATH
ruby -v

export RUBYLIB=/c/projects/openstudio/Ruby

cd /c/
curl -SLO https://rubygems.org/downloads/rubygems-update-2.6.7.gem
gem install --local /c/rubygems-update-2.6.7.gem
update_rubygems --no-ri --no-rdoc
gem update --system

cd /d/a/1/s/
bundle install

bundle list
/c/Ruby224-x64/ruby-2.2.4-x64-mingw32/bin/bundle list
