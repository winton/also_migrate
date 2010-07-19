# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'also_migrate/version'
require 'rubygems'
require 'bundler'

Gem::Specification.new do |s|
  s.name = "also_migrate"
  s.version = AlsoMigrate::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Winton Welsh"]
  s.email = ["mail@wintoni.us"]
  s.homepage = "http://github.com/winton/also_migrate"
  s.summary = "Migrate multiple tables with similar schema at once"
  s.description = "Migrate multiple tables with similar schema at once"

  Bundler.definition.dependencies.each do |dep|
    if dep.groups.include?(:gemspec)
      s.add_dependency dep.name, dep.requirement
    elsif dep.groups.include?(:gemspec_dev)
      s.add_development_dependency dep.name, dep.requirement
    end
  end

  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.executables = Dir.glob("{bin}/*").collect { |f| File.basename(f) }
  s.require_path = 'lib'
end