require "bundler/gem_tasks"

require 'rake/extensiontask'
Rake::ExtensionTask.new('prdx_engine')

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

BUNDLE = ENV['BUNDLE'] || %w[bundle].find { |c| system(c, '-v') }
task :test do
  sh "env #{BUNDLE} exec rake spec"  or exit 1
end
task :default => [ :test ]
