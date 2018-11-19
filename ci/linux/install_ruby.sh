#!/usr/bin/env bash
apt-get update
apt-get install -y build-essential curl autoconf libcurl4-openssl-dev zlib1g-dev zlibc ca-certificates libxml2-dev libyaml-dev libssl-dev libreadline-dev gcc
curl -fSL --retry 3 -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.4.tar.gz"
mkdir -p /tmp/ruby_src/ruby
tar -xzf ruby.tar.gz -C /tmp/ruby_src/ruby --strip-components=1
rm ruby.tar.gz
cd /tmp/ruby_src/ruby
{ echo '#define ENABLE_PATH_CHECK 0'; echo; cat file.c; } > file.c.new && mv file.c.new file.c
autoconf
./configure --disable-install-doc --enable-shared
make -j"$(nproc)"
make install
apt-get purge -y --auto-remove
gem update --system

sudo gem install bundler -v 1.16.6


echo "ruby version:"
ruby -v
