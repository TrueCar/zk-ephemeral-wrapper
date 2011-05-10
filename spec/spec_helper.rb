require "rubygems"

$LOAD_PATH.unshift(File.expand_path("#{File.dirname(__FILE__)}/../lib"))

require "bundler"
Bundler.setup

require "zk-ephemeral-wrapper"
ARGV.push("-b")
unless ARGV.include?("--format") || ARGV.include?("-f")
  ARGV.push("--format", "nested")
end

require 'rspec'
require 'rspec/autorun'
require 'rr'

Dir["#{File.dirname(__FILE__)}/spec_helpers/**/*.rb"].each do |file|
  require file
end

RSpec.configure do |configuration|
  configuration.mock_with :rr
  configuration.filter_run :focus => true
  configuration.run_all_when_everything_filtered = true
  configuration.before do
  end
end
