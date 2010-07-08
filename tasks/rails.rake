# http://www.metaskills.net/2010/5/26/the-alias_method_chain-of-rake-override-rake-task

Rake::TaskManager.class_eval do
  def alias_task(fq_name)
    new_name = "#{fq_name}:original"
    @tasks[new_name] = @tasks.delete(fq_name)
  end
end

def alias_task(fq_name)
  Rake.application.alias_task(fq_name)
end

def override_task(*args, &block)
  name, params, deps = Rake.application.resolve_args(args.dup)
  fq_name = Rake.application.instance_variable_get(:@scope).dup.push(name).join(':')
  alias_task(fq_name)
  Rake::Task.define_task(*args, &block)
end


namespace :db do
  namespace :test do
    override_task :prepare => :environment do
      # To invoke the original task add ":original" to its name
      ENV['from_db_test_prepare'] = "1"
      Rake::Task["db:test:prepare:original"].execute
    end
  end
end