require 'minitest/autorun'
require 'delegate'
require_relative '../lib/debug_me'

module ReceiverContextMixin
  LIMIT = 5
end

class ReceiverContextBox
  include ReceiverContextMixin
  @@shared = 'box'
end

ReceiverContextBase = Class.new { const_set(:SECRET_LEVEL, 3) }

class ReceiverContextParent
  SHADOWED = :parent
end

module ReceiverContextOuter
  SHADOWED = :outer

  class Child < ReceiverContextParent
    def go
      DebugMe.debug_me(file: nil, header: false, time: false, lvar: false, ivar: false, cvar: false) {}
    end
  end
end

class ReceiverContextRaw < BasicObject
  def go
    local_variable = 'local'
    local_variable.freeze # only discovery reads it; this keeps ruby -w quiet
    @instance_variable = 'instance'
    ::DebugMe.debug_me(file: nil, header: false, time: false) {}
  end
end

class ReceiverContextWrap < SimpleDelegator
  def go
    local_variable = 'local'
    local_variable.freeze # only discovery reads it; this keeps ruby -w quiet
    ::DebugMe.debug_me(file: nil, header: false, time: false, cconst: false) {}
  end
end


# Includes DebugMe, so DebugMe::DEBUG_ME_VERSION is among its constants
class ReceiverContextIncluder
  include DebugMe
  LIMIT = 3

  def show = debug_me(file: nil, header: false, time: false, lvar: false, ivar: false) {}
end


# Defines its own DEBUG_ME_VERSION, which must still be printed
class ReceiverContextOwnVersion
  include DebugMe
  DEBUG_ME_VERSION = 'mine'.freeze

  def show = debug_me(file: nil, header: false, time: false, lvar: false, ivar: false) {}
end


# Prepends DebugMe, yet its own DEBUG_ME_VERSION is what const_get returns
class ReceiverContextPrepender
  prepend DebugMe
  DEBUG_ME_VERSION = 'mine'.freeze

  def show = debug_me(file: nil, header: false, time: false, lvar: false, ivar: false) {}
end


# Gets DebugMe through a module it includes
module ReceiverContextHelpers
  include DebugMe
end


# Includes a module that includes DebugMe
class ReceiverContextNested
  include ReceiverContextHelpers
  LIMIT = 4

  def show = debug_me(file: nil, header: false, time: false, lvar: false, ivar: false) {}
end

describe "empty-block discovery reads from the block's receiver" do
  # These tests exercise debug_me's output, so turn it on even when the
  # shell has DEBUG_ME=false (which turns it off at require time).
  before do
    @saved_debug_me = $DEBUG_ME
    $DEBUG_ME = true
  end

  after { $DEBUG_ME = @saved_debug_me }

  it 'reads constants and class variables from the receiver inside class_exec' do
    output = ReceiverContextBox.class_exec { DebugMe.debug_me(file: nil, header: false, time: false) {} }

    _(output).must_include 'LIMIT -=> 5'
    _(output).must_include '@@shared -=> "box"'
  end

  it 'reads inherited constants from an anonymous subclass' do
    output = nil
    Class.new(ReceiverContextBase) { output = DebugMe.debug_me(file: nil, header: false, time: false) {} }

    _(output).must_include 'SECRET_LEVEL -=> 3'
  end

  it "prints the receiver's constant, not a same-named lexical one" do
    _(ReceiverContextOuter::Child.new.go).must_equal "DEBUG SHADOWED -=> :parent\n"
  end

  it 'discovers variables when self is a BasicObject' do
    output = ReceiverContextRaw.new.go

    _(output).must_include 'local_variable -=> "local"'
    _(output).must_include '@instance_variable -=> "instance"'
  end

  it "discovers the caller's locals when self is a Delegator" do
    output = ReceiverContextWrap.new([1, 2]).go

    _(output).must_include 'local_variable -=> "local"'
    _(output).wont_include '<undefined>'
  end

  it 'skips the constants a class gets from including DebugMe' do
    _(ReceiverContextIncluder.new.show).must_equal "DEBUG LIMIT -=> 3\n"
  end

  it 'skips them when DebugMe arrives through another included module' do
    _(ReceiverContextNested.new.show).must_equal "DEBUG LIMIT -=> 4\n"
  end

  it 'still prints a constant the class defines with the same name' do
    _(ReceiverContextOwnVersion.new.show).must_equal "DEBUG DEBUG_ME_VERSION -=> \"mine\"\n"
  end

  it 'still prints its own constant when the class prepends DebugMe' do
    _(ReceiverContextPrepender.new.show).must_equal "DEBUG DEBUG_ME_VERSION -=> \"mine\"\n"
  end
end

describe 'DebugMe.own_constant?' do
  it "is true for DebugMe's constant reached through include" do
    _(DebugMe.own_constant?(ReceiverContextIncluder, :DEBUG_ME_VERSION)).must_equal true
  end

  it 'is false for a same-named constant the class defines' do
    _(DebugMe.own_constant?(ReceiverContextOwnVersion, :DEBUG_ME_VERSION)).must_equal false
    _(DebugMe.own_constant?(ReceiverContextPrepender, :DEBUG_ME_VERSION)).must_equal false
  end

  it 'is false inside DebugMe itself, where the constants are its own' do
    _(DebugMe.own_constant?(DebugMe, :DEBUG_ME_VERSION)).must_equal false
  end

  it 'is false for a name DebugMe does not define' do
    _(DebugMe.own_constant?(ReceiverContextIncluder, :LIMIT)).must_equal false
  end
end
