AlsoMigrate
===========

Migrate multiple tables with similar schema at once.

Requirements
------------

<pre>
sudo gem install also_migrate
</pre>

Define the model
----------------

<pre>
class Article < ActiveRecord::Base
  also_migrate :article_archives, :ignore => 'moved_at', :indexes => 'id'
end
</pre>

Options:

* <code>ignore</code> Ignore migrations that apply to certain columns (defaults to none)
* <code>indexes</code> Only index certain columns (defaults to all)

That's it!
----------

Next time you migrate, <code>article_archives</code> is created if it doesn't exist.

Any new migration applied to <code>articles</code> is automatically applied to <code>article_archives</code>.