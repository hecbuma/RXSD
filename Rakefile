# rxsd project Rakefile
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# Licensed under the LGPLv3+ http://www.gnu.org/licenses/lgpl.txt

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :console do
  require 'rxsd'

  def reload!
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/rxsd\// }
    files.each { |file| load file }
  end

  ARGV.clear
  Pry.start
end

task :default => :test
