AlsoMigrate
===========

Migrate multiple tables with similar schema at once.

Requirements
------------

<pre>
gem install also_migrate
</pre>

Define the model
----------------

<pre>
class Article &lt; ActiveRecord::Base
  also_migrate(
    :article_archives,
    :add => [
      # Parameters to ActiveRecord::ConnectionAdapters::SchemaStatements#add_column
      [ 'deleted_at', :datetime, {} ]
    ],
    :subtract => 'restored_at',
    :ignore => 'deleted_at',
    :indexes => 'id'
  )
end
</pre>

Options:

* <code>add</code> Create columns that the original table doesn't have (defaults to none)
* <code>subtract</code> Exclude columns from the original table (defaults to none)
* <code>ignore</code> Ignore migrations that apply to certain columns (defaults to none)
* <code>indexes</code> Only index certain columns (duplicates all indexes by default)

That's it!
----------

Next time you migrate, <code>article_archives</code> is created if it doesn't exist.

Any new migration applied to <code>articles</code> is automatically applied to <code>article_archives</code>.