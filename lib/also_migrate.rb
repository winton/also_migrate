$:.unshift File.dirname(__FILE__) + '/also_migrate'

require 'version'
require 'base'
require 'migration'
require 'migrator'

ActiveRecord::Base.send(:include, AlsoMigrate::Base)
ActiveRecord::Migrator.send(:include, AlsoMigrate::Migrator)
ActiveRecord::Migration.send(:include, AlsoMigrate::Migration)