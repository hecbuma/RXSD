# rxsd project Rakefile
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# Licensed under the LGPLv3+ http://www.gnu.org/licenses/lgpl.txt
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

# Default directory to look in is `/specs`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format', 'documentation']
end

task :console do
  require 'pry'
  require 'rxsd'

  def reload!
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/rxsd\// }
    files.each { |file| load file }
  end

  ARGV.clear
  Pry.start
end

task :default => :spec
