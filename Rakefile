# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rake'
require 'rake/testtask'
require 'libfchat/version'

task :default => :test

task :test => [:test_webapi]

desc "build gem package"
task :build do
    sh 'gem build libfchat.gemspec'
    sh 'mv *.gem pkg/'
end

desc "Release new version of gem"
task :release => :build do
    sh "git tag -a v#{Libfchat::VERSION} -m 'Release #{Libfchat::VERSION}'"
    system "gem push pkg/libfchat-#{Libfchat::VERSION}"
end

Rake::TestTask.new(:test_webapi) do |t|
  t.libs << "test"
  t.test_files = FileList['test/webapi_test.rb']
  t.verbose = true
end
