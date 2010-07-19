source "http://rubygems.org"

v = {
  :active_wrapper => '=0.2.3',
  :bundler => '=1.0.0.beta.5',
  :mysql => '2.8.1',
  :rake => '=0.8.7',
  :rspec => '=1.3.0'
}

group :gemspec do
end

group :gemspec_dev do
  gem 'bundler', v[:bundler]
  gem 'rspec', v[:rspec]
end

group :rake do
  gem 'rake', v[:rake], :require => %w(rake rake/gempackagetask)
  gem 'rspec', v[:rspec], :require => %w(spec/rake/spectask)
end

group :spec do
  gem 'mysql', v[:mysql]
  gem 'active_wrapper', v[:active_wrapper]
  gem 'rspec', v[:rspec], :require => %w(
    spec/adapters/mock_frameworks/rspec
    spec/runner/formatter/progress_bar_formatter
    spec/runner/formatter/text_mate_formatter
  )
end