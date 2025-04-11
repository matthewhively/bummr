require "simplecov"
SimpleCov.start do
  # Exclude spec files from coverage
  add_filter '/spec/'

  git_branch_name = %x{git rev-parse --abbrev-ref HEAD}.strip
  SimpleCov.coverage_dir("coverage/#{git_branch_name}")
end

require 'pry'
require 'bummr'
require 'rainbow/ext/string'
require 'jet_black/rspec'

# Disable all colorize methods both in lib and spec files
# This makes it easier to compare plain strings
Rainbow.enabled = false

=begin
RSpec.configure do |config|
  # NOTE: before(:suite) does not allow mocking (allow, or allow_any_instance_of)
  config.before(:each) do

  end
end
=end
