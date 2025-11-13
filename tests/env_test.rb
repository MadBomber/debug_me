#!/usr/bin/env ruby
# Test script to verify ENV['DEBUG_ME'] initialization behavior
# This must be run as a separate process to test initialization

require 'minitest/autorun'

describe "DEBUG_ME environment variable initialization" do

  it "defaults to true when ENV['DEBUG_ME'] is not set" do
    # Remove the env var if it exists
    env_value = ENV.delete('DEBUG_ME')

    # Load the library fresh (in a subprocess to get clean initialization)
    result = `ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "true"

    # Restore if it was set
    ENV['DEBUG_ME'] = env_value if env_value
  end

  it "sets to false when ENV['DEBUG_ME'] is 'false'" do
    result = `DEBUG_ME=false ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "false"
  end

  it "sets to false when ENV['DEBUG_ME'] is 'no'" do
    result = `DEBUG_ME=no ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "false"
  end

  it "sets to false when ENV['DEBUG_ME'] is '0'" do
    result = `DEBUG_ME=0 ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "false"
  end

  it "sets to false when ENV['DEBUG_ME'] is 'off'" do
    result = `DEBUG_ME=off ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "false"
  end

  it "sets to false when ENV['DEBUG_ME'] is empty string" do
    result = `DEBUG_ME= ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "false"
  end

  it "sets to true when ENV['DEBUG_ME'] is 'true'" do
    result = `DEBUG_ME=true ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "true"
  end

  it "sets to true when ENV['DEBUG_ME'] is 'yes'" do
    result = `DEBUG_ME=yes ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "true"
  end

  it "sets to true when ENV['DEBUG_ME'] is '1'" do
    result = `DEBUG_ME=1 ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "true"
  end

  it "sets to true when ENV['DEBUG_ME'] is 'on'" do
    result = `DEBUG_ME=on ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "true"
  end

  it "sets to true when ENV['DEBUG_ME'] is any other value" do
    result = `DEBUG_ME=whatever ruby -I./lib -e 'require "debug_me"; p $DEBUG_ME' 2>&1`
    _(result.strip).must_equal "true"
  end

end
