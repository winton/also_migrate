require File.dirname(__FILE__) + '/also_migrate/gems'

AlsoMigrate::Gems.require(:lib)

$:.unshift File.dirname(__FILE__)

require 'also_migrate/version'

require 'also_migrate/base'
require 'also_migrate/migration'
require 'also_migrate/migrator'

module AlsoMigrate
  class <<self
    attr_accessor :classes
  end
end

ActiveRecord::Base.send(:include, AlsoMigrate::Base)
ActiveRecord::Migrator.send(:include, AlsoMigrate::Migrator)
ActiveRecord::Migration.send(:include, AlsoMigrate::Migration)