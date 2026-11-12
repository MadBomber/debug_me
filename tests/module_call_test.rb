require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require_relative '../lib/debug_me'

# BODY_OUTPUT runs at load time, so turn output on for the class bodies
# even when the shell has DEBUG_ME=false.
saved_debug_me = $DEBUG_ME
$DEBUG_ME = true

class ModuleCallContext
  CONSTANT = 'constant'
  autoload :UnloadedConstant, "#{__FILE__}.missing"
  @@class_variable = 'class'

  BODY_OUTPUT = DebugMe.debug_me(file: nil, header: false, time: false) {}

  def self.everything
    DebugMe.debug_me(file: nil, header: false, time: false) {}
  end

  def everything
    local_variable = 'local'
    @instance_variable = 'instance'
    DebugMe::debug_me(file: nil, header: false, time: false) {}
  end
end

module ModuleMethodContext
  CONSTANT = 'module constant'
  @@class_variable = 'module class'

  def self.everything
    DebugMe.debug_me(file: nil, header: false, time: false) {}
  end
end

$DEBUG_ME = saved_debug_me

describe "module-level debug_me" do
  # These tests exercise debug_me's output, so turn it on even when the
  # shell has DEBUG_ME=false (which turns it off at require time).
  before do
    @saved_debug_me = $DEBUG_ME
    $DEBUG_ME = true
  end

  after { $DEBUG_ME = @saved_debug_me }

  it "discovers class variables and constants inside a class method" do
    output = ModuleCallContext.everything

    _(output).must_include '@@class_variable -=> "class"'
    _(output).must_include 'CONSTANT -=> "constant"'
    _(output).wont_include 'UnloadedConstant'
    _(ModuleCallContext.autoload?(:UnloadedConstant)).wont_be_nil
  end

  it "discovers class variables and constants inside a class body" do
    output = ModuleCallContext::BODY_OUTPUT

    _(output).must_include '@@class_variable -=> "class"'
    _(output).must_include 'CONSTANT -=> "constant"'
  end

  it "discovers class variables and constants inside a module method" do
    output = ModuleMethodContext.everything

    _(output).must_include '@@class_variable -=> "module class"'
    _(output).must_include 'CONSTANT -=> "module constant"'
  end

  it "discovers the caller's variables from a module-level call" do
    output = ModuleCallContext.new.everything

    _(output).must_include 'local_variable -=> "local"'
    _(output).must_include '@instance_variable -=> "instance"'
    _(output).must_include '@@class_variable -=> "class"'
    _(output).must_include 'CONSTANT -=> "constant"'
  end

  # Other test files do a top-level include DebugMe, which puts DebugMe
  # into Object when the suite shares one process; a subprocess is the
  # only way to prove the call works with no include at all.
  it "works in a process that never includes DebugMe" do
    code = <<~CODE
      $DEBUG_ME = true
      require "debug_me"
      class Plain
        def call
          local_variable = "local"
          DebugMe.debug_me(file: nil, header: false, time: false) { :local_variable }
        end
      end
      print Object.ancestors.include?(DebugMe), "|", Plain.new.call
    CODE
    lib = File.expand_path("../lib", __dir__)
    env = { "DEBUG_ME" => nil, "RUBYOPT" => nil, "RUBYLIB" => nil }
    stdout, stderr, status = Open3.capture3(env, RbConfig.ruby, "-I#{lib}", "-e", code)

    assert status.success?, stderr
    _(stdout).must_equal %Q{false|DEBUG local_variable -=> "local"\n}
  end

  it "evaluates explicitly requested variables in the block binding" do
    value = 42
    output = DebugMe.debug_me(file: nil, header: false, time: false) { :value }

    _(output).must_equal "DEBUG value -=> 42\n"
  end

  it "does not trigger constant autoloads during automatic discovery" do
    output = ModuleCallContext.new.everything

    _(output).wont_include 'UnloadedConstant'
    _(ModuleCallContext.autoload?(:UnloadedConstant)).wont_be_nil
  end

  it "reports the caller rather than an internal wrapper" do
    line = __LINE__ + 1
    output = DebugMe.debug_me(file: nil, time: false)

    _(output).must_include "#{__FILE__}:#{line}:"
  end

  it "preserves the public included method" do
    object = Object.new.extend(DebugMe)
    value = 42
    output = object.debug_me(file: nil, header: false, time: false) { :value }

    _(output).must_equal "DEBUG value -=> 42\n"
  end

  it "does not evaluate the block when debugging is disabled" do
    original = $DEBUG_ME
    $DEBUG_ME = false
    evaluated = false

    output = DebugMe.debug_me(file: nil) { evaluated = true }

    _(output).must_be_nil
    _(evaluated).must_equal false
  ensure
    $DEBUG_ME = original
  end
end
