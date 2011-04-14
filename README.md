AlsoMigrate
===========

Migrate multiple tables with similar schema at once.

Requirements
------------


    gem install also_migrate


Configure
---------

In your migration:


    class CreateArticleArchives < ActiveRecord::Migration
      def self.up
        AlsoMigrate.configuration = [
          {
            :source => 'articles',
            :destination => 'article_archives',
            :add => [
              # Parameters to ActiveRecord::ConnectionAdapters::SchemaStatements#add_column
              [ 'deleted_at', :datetime, {} ]
            ],
            :subtract => 'restored_at',
            :ignore => 'deleted_at',
            :indexes => 'id'
          },
          {
            :source => 'users',
            :destination => [ 'banned_users', 'deleted_users' ]
          }
        ]
        AlsoMigrate::Migrator.migrate
      end
    
      def self.down
      end
    end

Options:

* `source` Database schema source table
* `destination` Database schema destination table (can also be an array of tables)
* `add` Create columns that the original table doesn't have (defaults to none)
* `subtract` Exclude columns from the original table (defaults to none)
* `ignore` Ignore migrations that apply to certain columns (defaults to none)
* `indexes` Only index certain columns (duplicates all indexes by default)

That's it!
----------