require 'minitest/autorun'
require_relative '../lib/debug_me'

# A local named backtrace is common in rescue code (backtrace = e.backtrace)
class BacktraceLocalHolder
  def show
    backtrace = %w[my data]
    backtrace.freeze # only discovery reads it; this keeps ruby -w quiet
    DebugMe.debug_me(file: nil, time: false, header: false, ivar: false, cvar: false, cconst: false) {}
  end

  def show_explicit
    backtrace = %w[my data]
    backtrace.freeze
    DebugMe.debug_me(file: nil, time: false, header: false) { :backtrace }
  end
end

describe 'a local variable named backtrace' do
  before do
    @saved_debug_me = $DEBUG_ME
    $DEBUG_ME = true
  end

  after { $DEBUG_ME = @saved_debug_me }

  it 'prints its value in an empty-block dump' do
    _(BacktraceLocalHolder.new.show).must_equal "DEBUG backtrace -=> #{%w[my data].pretty_inspect}"
  end

  it 'leaves an explicit :backtrace meaning the call stack' do
    output = BacktraceLocalHolder.new.show_explicit

    _(output).must_include 'DEBUG backtrace -=> ['
    _(output).wont_include '"my"'
  end
end
