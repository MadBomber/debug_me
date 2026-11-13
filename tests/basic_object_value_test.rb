# frozen_string_literal: true

require 'minitest/autorun'
require 'delegate'
require_relative '../lib/debug_me'

# Holds a BasicObject in an ivar for empty-block discovery
class BasicObjectValueHolder
  # A BasicObject that names itself
  class Named < BasicObject
    def inspect = 'named'
  end

  # A BasicObject holding another one
  class Nested < BasicObject
    def initialize
      @inner = ::BasicObject.new
    end
  end

  # A BasicObject that forwards every call to its target
  class Proxy < BasicObject
    def initialize(target)
      @target = target
    end

    def method_missing(name, ...) = @target.__send__(name, ...)

    def respond_to_missing?(name, include_private = false) = @target.respond_to?(name, include_private)
  end

  def go
    @raw = BasicObject.new
    DebugMe.debug_me(file: nil, header: false, time: false, lvar: false, cvar: false, cconst: false) {}
  end
end

describe 'a BasicObject value' do
  # These tests exercise debug_me's output, so turn it on even when the
  # shell has DEBUG_ME=false (which turns it off at require time).
  before do
    @saved_debug_me = $DEBUG_ME
    $DEBUG_ME = true
  end

  after { $DEBUG_ME = @saved_debug_me }

  it 'is printed when the block returns it' do
    raw = BasicObject.new

    output = DebugMe.debug_me(file: nil, header: false, time: false) { raw }

    _(output).must_match(/\ADEBUG BasicObject -=> #<BasicObject:0x\h+>\n\z/)
  end

  it 'is printed when a Symbol names the local holding it' do
    _raw = BasicObject.new

    output = DebugMe.debug_me(file: nil, header: false, time: false) { :_raw }

    _(output).must_match(/\ADEBUG _raw -=> #<BasicObject:0x\h+>\n\z/)
  end

  it 'uses its own inspect when it has one' do
    named = BasicObjectValueHolder::Named.new

    output = DebugMe.debug_me(file: nil, header: false, time: false) { named }

    _(output).must_equal "DEBUG BasicObjectValueHolder::Named -=> named\n"
  end

  it 'is printed when it holds another BasicObject' do
    nested = BasicObjectValueHolder::Nested.new

    output = DebugMe.debug_me(file: nil, header: false, time: false) { nested }

    _(output).must_match(/\ADEBUG BasicObjectValueHolder::Nested -=> #<BasicObjectValueHolder::Nested:0x\h+>\n\z/)
  end

  it 'leaves a forwarding proxy printed as its target' do
    proxy = BasicObjectValueHolder::Proxy.new({ a: 1 })

    output = DebugMe.debug_me(file: nil, header: false, time: false) { proxy }

    _(output).must_equal "DEBUG Hash -=> #{{ a: 1 }.inspect}\n"
  end

  it 'leaves a Delegator printed as its target' do
    _wrapped = SimpleDelegator.new([1, 2])

    output = DebugMe.debug_me(file: nil, header: false, time: false) { :_wrapped }

    _(output).must_equal "DEBUG _wrapped -=> [1, 2]\n"
  end

  it 'is printed when an empty block discovers the ivar holding it' do
    _(BasicObjectValueHolder.new.go).must_match(/\ADEBUG @raw -=> #<BasicObject:0x\h+>\n\z/)
  end

  it 'treats a Delegator wrapping "backtrace" as a value, not the backtrace marker' do
    marker = SimpleDelegator.new('backtrace')

    output = DebugMe.debug_me(file: nil, time: false, levels: 1) { marker }

    _(output).must_include 'DEBUG backtrace -=> '
    _(output).must_include 'DEBUG SimpleDelegator -=> "backtrace"'
  end
end
