require 'minitest/autorun'
require_relative '../lib/debug_me'

class ModuleCallContext
  CONSTANT = 'constant'
  autoload :UnloadedConstant, "#{__FILE__}.missing"
  @@class_variable = 'class'

  def everything
    local_variable = 'local'
    @instance_variable = 'instance'
    DebugMe::debug_me(file: nil, header: false, time: false) {}
  end
end

describe "module-level debug_me" do
  it "works without including DebugMe" do
    _(ModuleCallContext.ancestors).wont_include DebugMe
    output = ModuleCallContext.new.everything

    _(output).must_include 'local_variable -=> "local"'
    _(output).must_include '@instance_variable -=> "instance"'
    _(output).must_include '@@class_variable -=> "class"'
    _(output).must_include 'CONSTANT -=> "constant"'
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

  it "accepts string and integer backtrace levels" do
    [2, "2"].each do |levels|
      output = DebugMe.debug_me(file: nil, time: false, levels: levels)

      _(output).must_include 'Source:'
      _(output).must_include 'backtrace -=>'
      assert_match(/\[0,\s/, output)
      assert_match(/\[1,\s/, output)
      refute_match(/\[2,\s/, output)
    end
  end

  it "omits backtrace entries for nonpositive string levels" do
    ["0", "-1"].each do |levels|
      output = DebugMe.debug_me(file: nil, time: false, levels: levels)

      _(output).must_include 'Source:'
      _(output).wont_include 'backtrace'
    end
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
