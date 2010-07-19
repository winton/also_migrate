require 'rubygems'
require 'bundler'

Bundler.require(:spec)

SPEC = File.dirname(__FILE__)

require 'pp'
require "#{Bundler.root}/rails/init"
require "#{Bundler.root}/spec/fixtures/article"

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