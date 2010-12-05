require File.dirname(__FILE__) + '/also_migrate/gems'

AlsoMigrate::Gems.require(:lib)

$:.unshift File.dirname(__FILE__) + '/also_migrate'

require 'base'
require 'migration'
require 'migrator'
require 'version'

module AlsoMigrate
  class <<self
    attr_accessor :classes
  end
end

ActiveRecord::Base.send(:include, AlsoMigrate::Base)
ActiveRecord::Migrator.send(:include, AlsoMigrate::Migrator)
ActiveRecord::Migration.send(:include, AlsoMigrate::Migration)