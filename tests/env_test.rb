#!/usr/bin/env ruby
# Test script to verify ENV['DEBUG_ME'] initialization behavior
# This must be run as a separate process to test initialization

require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'tmpdir'

describe "DEBUG_ME environment variable initialization" do

  # Load the library fresh in a subprocess so initialization is clean, and
  # return the resulting $DEBUG_ME value from stdout only. A cleared env keeps
  # the parent's DEBUG_ME/RUBYOPT/RUBYLIB from leaking in, and reading stdout
  # (never merged stderr) keeps parent-env noise out of the asserted value.
  # Pass nil for debug_me_value to leave DEBUG_ME unset.
  def debug_me_flag(debug_me_value)
    lib = File.expand_path('../lib', __dir__)
    env = { 'DEBUG_ME' => debug_me_value, 'RUBYOPT' => nil, 'RUBYLIB' => nil }
    stdout, _stderr, _status = Open3.capture3(env, RbConfig.ruby, "-I#{lib}", '-e', 'require "debug_me"; p $DEBUG_ME')
    stdout.strip
  end

  it "defaults to true when ENV['DEBUG_ME'] is not set" do
    _(debug_me_flag(nil)).must_equal "true"
  end

  it "sets to false when ENV['DEBUG_ME'] is 'false'" do
    _(debug_me_flag('false')).must_equal "false"
  end

  it "sets to false when ENV['DEBUG_ME'] is 'no'" do
    _(debug_me_flag('no')).must_equal "false"
  end

  it "sets to false when ENV['DEBUG_ME'] is '0'" do
    _(debug_me_flag('0')).must_equal "false"
  end

  it "sets to false when ENV['DEBUG_ME'] is 'off'" do
    _(debug_me_flag('off')).must_equal "false"
  end

  it "sets to false when ENV['DEBUG_ME'] is empty string" do
    _(debug_me_flag('')).must_equal "false"
  end

  it "sets to true when ENV['DEBUG_ME'] is 'true'" do
    _(debug_me_flag('true')).must_equal "true"
  end

  it "sets to true when ENV['DEBUG_ME'] is 'yes'" do
    _(debug_me_flag('yes')).must_equal "true"
  end

  it "sets to true when ENV['DEBUG_ME'] is '1'" do
    _(debug_me_flag('1')).must_equal "true"
  end

  it "sets to true when ENV['DEBUG_ME'] is 'on'" do
    _(debug_me_flag('on')).must_equal "true"
  end

  it "sets to true when ENV['DEBUG_ME'] is any other value" do
    _(debug_me_flag('whatever')).must_equal "true"
  end

  describe "requiring with warnings enabled" do
    def require_debug_me_with_warnings(code = 'require "debug_me"')
      lib = File.expand_path('../lib', __dir__)
      env = { 'DEBUG_ME' => nil, 'RUBYOPT' => nil, 'RUBYLIB' => nil }
      Open3.capture3(env, RbConfig.ruby, '-w', '--disable-gems', "-I#{lib}", '-e', code)
    end

    it "requires cleanly, with no warnings" do
      _stdout, stderr, status = require_debug_me_with_warnings
      _(stderr).must_be_empty
      _(status.success?).must_equal true
    end

    it "keeps a $DEBUG_ME set to false before require" do
      stdout, stderr, status = require_debug_me_with_warnings('$DEBUG_ME = false; require "debug_me"; p $DEBUG_ME')
      _(stderr).must_be_empty
      _(status.success?).must_equal true
      _(stdout.strip).must_equal "false"
    end

    it "treats a $DEBUG_ME set to nil before require as unset" do
      stdout, stderr, status = require_debug_me_with_warnings('$DEBUG_ME = nil; require "debug_me"; p $DEBUG_ME')
      _(stderr).must_be_empty
      _(status.success?).must_equal true
      _(stdout.strip).must_equal "true"
    end
  end

  it 'runs the main test file green and leaves no files when DEBUG_ME=false' do
    test_file = File.expand_path('debug_me_test.rb', __dir__)
    Dir.mktmpdir do |dir|
      output, status = Open3.capture2e({ 'DEBUG_ME' => 'false' }, RbConfig.ruby, test_file, chdir: dir)
      assert status.success?, output
      _(Dir.entries(dir) - %w[. ..]).must_be_empty
    end
  end

end
