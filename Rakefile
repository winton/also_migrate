require 'rubygems'
require 'bundler'

Bundler.require(:rake)

def gemspec
  @gemspec ||= begin
    file = File.expand_path('../also_migrate.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

if defined?(Rake::GemPackageTask)
  Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.gem_spec = gemspec
  end
  task :gem => :gemspec
end

if defined?(Spec::Rake::SpecTask)
  desc "Run specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = %w(-fs --color)
    t.warning = true
  end
  task :spec
end

desc "Install gem locally"
task :install => :package do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}}
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

task :package => :gemspec
task :default => :spec