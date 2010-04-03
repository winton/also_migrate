require File.expand_path("#{File.dirname(__FILE__)}/../require")
Require.spec_helper!

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

def migrate_with_state(version)
  @old_article_columns = columns("articles")
  @old_archive_columns = columns("article_archives")
  $db.migrate(version)
  @new_article_columns = columns("articles")
  @new_archive_columns = columns("article_archives")
end