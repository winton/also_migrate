require 'rubygems'
gem 'require'
require 'require'

Require do
  gem(:active_wrapper, '=0.2.3') { require 'active_wrapper' }
  gem :require, '=0.2.6'
  gem(:rake, '=0.8.7') { require 'rake' }
  gem :rspec, '=1.3.0'
  
  gemspec do
    author 'Winton Welsh'
    dependencies do
      gem :require
    end
    email 'mail@wintoni.us'
    name 'also_migrate'
    homepage "http://github.com/winton/#{name}"
    summary "Migrate multiple tables with similar schema"
    version '0.1.0'
  end
  
  bin { require 'lib/also_migrate' }
  
  lib do
    require 'lib/also_migrate/base'
    require 'lib/also_migrate/migration'
    require 'lib/also_migrate/migrator'
  end
  
  rails_init { require 'lib/also_migrate' }
  
  rakefile do
    gem(:active_wrapper)
    gem(:rake) { require 'rake/gempackagetask' }
    gem(:rspec) { require 'spec/rake/spectask' }
    require 'require/tasks'
  end
  
  spec_helper do
    gem(:active_wrapper)
    require 'require/spec_helper'
    require 'rails/init'
    require 'pp'
    require 'spec/fixtures/article'
  end
  
  spec_rakefile do
    gem(:rake)
    gem(:active_wrapper) { require 'active_wrapper/tasks' }
  end
end
