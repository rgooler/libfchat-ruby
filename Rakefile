# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rake'
require 'rspec/core/rake_task'
require 'libfchat/version'

task :default => :test

task :test => [:spec]

desc "build gem package"
task :build do
    sh 'gem build libfchat.gemspec'
end

desc "Release new version of gem"
task :release => :build do
    sh "git tag -a v#{Libfchat::VERSION} -m 'Release #{Libfchat::VERSION}'"
    sh "git push --tags"
    system "gem push libfchat-#{Libfchat::VERSION}.gem"
    sh 'mv *.gem pkg/'
end

RSpec::Core::RakeTask.new do |t|
  t.ruby_opts = '-w'
  t.rspec_opts = '--color --format documentation'
end
