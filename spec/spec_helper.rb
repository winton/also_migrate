require 'pp'

$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/also_migrate/gems"

AlsoMigrate::Gems.activate :active_wrapper, :rspec

require 'active_wrapper'

require "#{$root}/lib/also_migrate"
require "#{$root}/spec/fixtures/article"
require "#{$root}/spec/fixtures/comment"
require 'pp'

Spec::Runner.configure do |config|
end

$db, $log, $mail = ActiveWrapper.setup(
  :base => File.dirname(__FILE__),
  :env => 'test'
)
$db.establish_connection

def columns(table)
  connection.columns(table).collect(&:name)
end

def connection
  ActiveRecord::Base.connection
end

# For use with rspec textmate bundle
def debug(object)
  puts "<pre>"
  puts object.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
  puts "</pre>"
end

def indexed_columns(table_name)
  # MySQL
  if connection.class.to_s.include?('Mysql')
    index_query = "SHOW INDEX FROM #{table_name}"
    connection.select_all(index_query).collect do |r|
      r["Column_name"]
    end
  # PostgreSQL
  # http://stackoverflow.com/questions/2204058/show-which-columns-an-index-is-on-in-postgresql/2213199
  elsif connection.class.to_s.include?('PostgreSQL')
    index_query = <<-SQL
      select
        t.relname as table_name,
        i.relname as index_name,
        a.attname as column_name
      from
        pg_class t,
        pg_class i,
        pg_index ix,
        pg_attribute a
      where
        t.oid = ix.indrelid
        and i.oid = ix.indexrelid
        and a.attrelid = t.oid
        and a.attnum = ANY(ix.indkey)
        and t.relkind = 'r'
        and t.relname = '#{table_name}'
      order by
        t.relname,
        i.relname
    SQL
    connection.select_all(index_query).collect do |r|
      r["column_name"]
    end
  else
    raise 'AlsoMigrate does not support this database adapter'
  end
end

def migrate_with_state(version)
  @old_article_columns = columns("articles")
  @old_archive_columns = columns("article_archives")
  $db.migrate(version)
  @new_article_columns = columns("articles")
  @new_archive_columns = columns("article_archives")
end

def reset_fixture
  if Article.respond_to?(:also_migrate_config)
    Article.also_migrate_config = nil
  end
  
  if Comment.respond_to?(:also_migrate_config)
    Comment.also_migrate_config = nil
  end
  
  if connection.table_exists?('article_archives')
    connection.execute('DROP TABLE article_archives')
  end
  
  if connection.table_exists?('comment_archives')
    connection.execute('DROP TABLE comment_archives')
  end
end