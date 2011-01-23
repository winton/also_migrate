AlsoMigrate
===========

Migrate multiple tables with similar schema at once.

Requirements
------------

<pre>
gem install also_migrate
</pre>

Configure
---------

<pre>
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
</pre>

Options:

* <code>source</code> Database schema source table
* <code>destination</code> Database schema destination table (can also be an array of tables)
* <code>add</code> Create columns that the original table doesn't have (defaults to none)
* <code>subtract</code> Exclude columns from the original table (defaults to none)
* <code>ignore</code> Ignore migrations that apply to certain columns (defaults to none)
* <code>indexes</code> Only index certain columns (duplicates all indexes by default)

That's it!
----------

Next time you migrate, <code>article_archives</code> is created if it doesn't exist.

Any new migration applied to <code>articles</code> is automatically applied to <code>article_archives</code>.