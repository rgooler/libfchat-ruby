# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rake'
require 'rake/testtask'
require 'libfchat/version'

task :default => :test

task :test => [:test_all]

desc "build gem package"
task :build do
    sh 'gem build libfchat.gemspec'
end

desc "Release new version of gem"
task :release => :build do
    sh "git tag -a v#{Libfchat::VERSION} -m 'Release #{Libfchat::VERSION}'"
    system "gem push libfchat-#{Libfchat::VERSION}.gem"
    sh 'mv *.gem pkg/'
end

Rake::TestTask.new(:test_all) do |t|
  t.libs << "test"
  t.test_files = FileList['test/webapi_test.rb','test/fchat_test.rb']
  t.verbose = true
end
