# -*- encoding: utf-8 -*-
root = File.dirname(__FILE__)
lib = "#{root}/lib"
$:.unshift lib unless $:.include?(lib)
 
require 'also_migrate/gems'
AlsoMigrate::Gems.gemset ||= ENV['GEMSET'] || :default

Gem::Specification.new do |s|
  AlsoMigrate::Gems.gemspec.hash.each do |key, value|
    if key == 'name' && AlsoMigrate::Gems.gemset != :default
      s.name = "#{value}-#{AlsoMigrate::Gems.gemset}"
    elsif key == 'summary' && AlsoMigrate::Gems.gemset == :solo
      s.summary = value + " (no dependencies)"
    elsif !%w(dependencies development_dependencies).include?(key)
      s.send "#{key}=", value
    end
  end

  AlsoMigrate::Gems.dependencies.each do |g|
    s.add_dependency g.to_s, AlsoMigrate::Gems.versions[g]
  end
  
  AlsoMigrate::Gems.development_dependencies.each do |g|
    s.add_development_dependency g.to_s, AlsoMigrate::Gems.versions[g]
  end

  s.executables = `cd #{root} && git ls-files -- {bin}/*`.split("\n").collect { |f| File.basename(f) }
  s.files = `cd #{root} && git ls-files`.split("\n")
  s.require_paths = %w(lib)
  s.test_files = `cd #{root} && git ls-files -- {features,test,spec}/*`.split("\n")
end