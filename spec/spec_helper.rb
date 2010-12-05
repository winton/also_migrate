$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/also_migrate/gems"

AlsoMigrate::Gems.require(:spec)

require 'active_wrapper'

require "#{$root}/lib/also_migrate"
require "#{$root}/spec/fixtures/article"
require 'pp'

Spec::Runner.configure do |config|
end

$db, $log, $mail = ActiveWrapper.setup(
  :base => File.dirname(__FILE__),
  :env => 'development'
)
$db.establish_connection

def columns(table)
  connection.columns(table).collect(&:name)
end

def connection
  ActiveRecord::Base.connection
end

def migrate_with_state(version)
  @old_article_columns = columns("articles")
  @old_archive_columns = columns("article_archives")
  $db.migrate(version)
  @new_article_columns = columns("articles")
  @new_archive_columns = columns("article_archives")
end

# For use with rspec textmate bundle
def debug(object)
  puts "<pre>"
  puts object.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
  puts "</pre>"
end