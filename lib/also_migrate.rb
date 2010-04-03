require File.expand_path("#{File.dirname(__FILE__)}/../require")
Require.lib!

ActiveRecord::Base.send(:include, AlsoMigrate::Base)
ActiveRecord::Migrator.send(:include, AlsoMigrate::Migrator)
ActiveRecord::Migration.send(:include, AlsoMigrate::Migration)