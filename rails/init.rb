require File.expand_path(File.dirname(__FILE__) + '/../lib/also_migrate')

unless $override_rails_rake_task == false
  $rails_rake_task = false
end