# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'also_migrate/gems'
require 'also_migrate/version'

Gem::Specification.new do |s|
  s.name = "also_migrate"
  s.version = AlsoMigrate::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Winton Welsh"]
  s.email = ["mail@wintoni.us"]
  s.homepage = "http://github.com/winton/also_migrate"
  s.summary = ""
  s.description = ""

  AlsoMigrate::Gems::TYPES[:gemspec].each do |g|
    s.add_dependency g.to_s, AlsoMigrate::Gems::VERSIONS[g]
  end
  
  AlsoMigrate::Gems::TYPES[:gemspec_dev].each do |g|
    s.add_development_dependency g.to_s, AlsoMigrate::Gems::VERSIONS[g]
  end

  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.executables = Dir.glob("{bin}/*").collect { |f| File.basename(f) }
  s.require_path = 'lib'
end