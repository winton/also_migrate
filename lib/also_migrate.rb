require File.dirname(__FILE__) + '/also_migrate/gems'

$:.unshift File.dirname(__FILE__)

require 'also_migrate/migration'
require 'also_migrate/migrator'

module AlsoMigrate
  class <<self
    attr_accessor :configuration
  end
end
