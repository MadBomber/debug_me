#!/usr/bin/env ruby

require 'logger'
require 'stringio'
require 'tmpdir'

require_relative '../lib/debug_me'
include DebugMe

require_relative './world_view'



require 'minitest/autorun'

describe DebugMe do

  # These tests exercise debug_me's output, so turn it on even when the
  # shell has DEBUG_ME=false (which turns it off at require time).
  before do
    @saved_debug_me = $DEBUG_ME
    $DEBUG_ME = true
  end

  after { $DEBUG_ME = @saved_debug_me }

  describe "source header included" do

  	before do
  	  @line = __LINE__
  	  @file = __FILE__
  	  @out_string = debug_me(file:nil)
  	end

    it "has the keywords DEBUG and Source" do
      assert @out_string.include? "DEBUG"
      assert @out_string.include? "Source"
    end

    it "includes the filename" do
      assert @out_string.include? __FILE__
    end

    it "includes the line number" do
      assert @out_string.include? ".rb:#{@line+2}:"
    end

  end # describe "source header included" do

  describe "bounded call stack capture" do
    before do
      @debugger = Object.new.extend(DebugMe)
      @frames = ['header.rb:1', 'parent.rb:2', 'grandparent.rb:3', 'ancestor.rb:4']
      @captures = []
      frames, captures = @frames, @captures
      @debugger.define_singleton_method(:caller) do |start, length|
        captures << [start, length]
        frames.first(length)
      end
    end

    it "captures only the header frame for ordinary variable output" do
      value = 42
      output = @debugger.debug_me(file: nil, time: false) { :value }

      _(@captures).must_equal [[1, 1]]
      _(output).must_equal "DEBUG Source:  header.rb:1\nDEBUG value -=> 42\n"
    end

    it "does not capture a stack when the header is disabled" do
      value = 42
      output = @debugger.debug_me(file: nil, header: false, levels: 2) { :value }

      _(@captures).must_be_empty
      _(output).must_include 'value -=> 42'
    end

    it "captures only the requested levels and preserves their numbering" do
      output = @debugger.debug_me(file: nil, time: false, levels: 2)

      _(@captures).must_equal [[1, 1], [1, 3]]
      _(output).must_equal "DEBUG Source:  header.rb:1\nDEBUG backtrace -=> #{[[0, @frames[1]], [1, @frames[2]]].pretty_inspect}"
    end

    it "lets levels supersede an explicit backtrace" do
      output = @debugger.debug_me(file: nil, levels: 2) { :backtrace }

      _(@captures).must_equal [[1, 1], [1, 3]]
      _(output).wont_include @frames[3]
    end

    it "caps explicit backtraces and captures them only once" do
      output = @debugger.debug_me(file: nil, header: false, time: false, levels: 2) { [:backtrace, 'backtrace'] }

      _(@captures).must_equal [[1, DEBUG_ME_MAX_BACKTRACE + 1]]
      _(output).must_equal "DEBUG backtrace -=> #{@frames.drop(1).pretty_inspect}" * 2
    end

    it "captures a bounded explicit backtrace alongside the header" do
      output = @debugger.debug_me(file: nil, time: false) { :backtrace }

      _(@captures).must_equal [[1, 1], [1, DEBUG_ME_MAX_BACKTRACE + 1]]
      _(output).must_equal "DEBUG Source:  header.rb:1\nDEBUG backtrace -=> #{@frames.drop(1).pretty_inspect}"
    end

    it "preserves integer conversion and handles fewer frames than requested" do
      output = @debugger.debug_me(file: nil, levels: 5.9)

      _(@captures).must_equal [[1, 1], [1, 6]]
      _(output).must_include @frames.last
    end

    it "does not treat a non-String value whose to_s is backtrace as the marker" do
      marker = Object.new
      def marker.to_s = 'backtrace'
      output = @debugger.debug_me(file: nil, header: false, time: false) { marker }

      _(@captures).must_be_empty
      _(output).wont_include 'DEBUG backtrace -=>'
    end

    it "keeps the levels backtrace when a non-String value's to_s is backtrace" do
      marker = Object.new
      def marker.to_s = 'backtrace'
      output = @debugger.debug_me(file: nil, time: false, levels: 1) { marker }

      _(output).must_include "DEBUG backtrace -=> #{[[0, @frames[1]]].pretty_inspect}"
    end

    it "does not include the calling frame in a real explicit backtrace" do
      expected = caller(1, DEBUG_ME_MAX_BACKTRACE)
      output = debug_me(file: nil, header: false, time: false) { :backtrace }

      _(output).must_equal "DEBUG backtrace -=> #{expected.pretty_inspect}"
    end
  end


  describe "Add more from the call stack" do

    before do
      @my_world_view = WorldView.new
    end

    it 'supports multiple levels from the call stack' do
      result = @my_world_view.one
      # debug_me returns everything as one big long string
      # with embedded new lines.  In the WorldView class
      # method six is called from five, which is called from four, three, two, one.
      # The ":levels" options is set to 5 so we get the normal source header
      # plus 5 backtrace entries. Due to pretty_inspect formatting with long
      # file paths, each entry may span multiple lines.
      # Verify we have the header and all 5 backtrace entries:
      assert result.include?("Source:")
      assert result.include?("backtrace")
      assert result.include?("five")
      assert result.include?("four")
      assert result.include?("three")
      assert result.include?("two")
      assert result.include?("one")
    end

    it 'prints the backtrace once when levels is set and the block asks for :backtrace' do
      @answer = 42
      result = debug_me(file: nil, levels: 1) { [:@answer, :backtrace] }
      assert_equal 1, result.scan(' backtrace -=> ').size
      # the levels-limited form ([[level, frame]]) is the one kept
      assert_includes result, ' backtrace -=> [[0,'
      assert_includes result, ' @answer -=> 42'
      # it stays where the block listed it
      assert_operator result.index(' @answer -=> '), :<, result.index(' backtrace -=> ')
    end

it 'puts the levels backtrace first when the block does not list it' do
  @answer = 42
  result = debug_me(file: nil, levels: 1) { :@answer }
  assert_operator result.index(' backtrace -=> [[0,'), :<, result.index(' @answer -=> ')
end

    it 'accepts a String levels value' do
      result = debug_me(file: nil, levels: '2') { :x }
      assert_includes result, ' backtrace -=> [[0,'
      assert_includes result, ' [1,'
      refute_includes result, ' [2,'
    end

it 'prints the full backtrace once when levels is not set' do
      result = debug_me(file: nil) { :backtrace }
      assert_equal 1, result.scan(' backtrace -=> ').size
      refute_includes result, ' backtrace -=> [[0,'
    end
  end


  describe "source header excluded" do

  	before do
  	  @out_string = debug_me(file:nil,header:false)
  	end

    it "is empty" do
      assert @out_string.empty?
    end

  end # describe "source header excluded" do


  describe 'skip1 and skip2' do
    before { @skipped = 1 }

    it 'adds one blank line before output without a header' do
      out_string = debug_me(file: nil, time: false, header: false, skip1: true) { :@skipped }
      _(out_string).must_equal "\nDEBUG @skipped -=> 1\n"
    end

    it 'adds two blank lines before output without a header' do
      out_string = debug_me(file: nil, time: false, header: false, skip2: true) { :@skipped }
      _(out_string).must_equal "\n\nDEBUG @skipped -=> 1\n"
    end

    it 'puts the blank lines before the header' do
      out_string = debug_me(file: nil, time: false, skip2: true) { :@skipped }
      _(out_string).must_match(/\A\n\nDEBUG Source:  .+\nDEBUG @skipped -=> 1\n\z/)
    end
  end


  describe "String tag shorthand" do

    it "accepts other options after the String tag" do
      answer = 42
      out_string = debug_me('MYTAG', file: nil, time: false, header: false) { :answer }
      _(out_string).must_equal "MYTAG answer -=> 42\n"
    end

    it "lets keyword options supplement a positional options Hash" do
      answer = 42
      out_string = debug_me({ tag: 'MYTAG', file: nil }, time: false, header: false) { :answer }
      _(out_string).must_equal "MYTAG answer -=> 42\n"
    end

  end # describe "String tag shorthand" do


  describe "works with local variable" do

    it "supports a single variable" do
      a,b,c = 1,2,3
      out_string = debug_me(file:nil,header:false){:a}
      assert out_string.include? "a -=> #{a}"
      _(out_string.split("\n").size).must_equal 1
    end

    it "supports multiple variables" do
      a,b,c = 1,2,3
      out_string = debug_me(file:nil,header:false){[:a, :b, :c]}
      assert out_string.include? "a -=> #{a}"
      assert out_string.include? "b -=> #{b}"
      assert out_string.include? "c -=> #{c}"
      _(out_string.split("\n").size).must_equal 3
    end

    it "shows all local variables" do
      a,b,c = 1,2,3
      out_string = debug_me(
        file:nil,
        header:false,
        lvar: true,
        ivar: false,
        cvar: false,
        cconst: false
        ){}
      assert out_string.include? "a -=> #{a}"
      assert out_string.include? "b -=> #{b}"
      assert out_string.include? "c -=> #{c}"
      assert out_string.include? "out_string -=> "

      _(out_string.split("\n").size).must_equal 4
    end

  end # describe "works with local variable" do

  describe "works with instance variable" do

    it "supports a single variable" do
      @a,@b,@c = 1,2,3
      out_string = debug_me(file:nil,header:false){:@a}
      assert out_string.include? "@a -=> #{@a}"
      _(out_string.split("\n").size).must_equal 1
    end

    it "supports multiple variables" do
      @a,@b,@c = 1,2,3
      out_string = debug_me(file:nil,header:false){[:@a, :@b, :@c]}
      assert out_string.include? "@a -=> #{@a}"
      assert out_string.include? "@b -=> #{@b}"
      assert out_string.include? "@c -=> #{@c}"
      _(out_string.split("\n").size).must_equal 3
    end

    it "shows all instance variables" do
      @a,@b,@c = 1,2,3
      out_string = debug_me(
        file:nil,
        header:false,
        lvar: false,
        ivar: true,
        cvar: false,
        cconst: false
        ){}
      assert out_string.include? "@a -=> #{@a}"
      assert out_string.include? "@b -=> #{@b}"
      assert out_string.include? "@c -=> #{@c}"

      _(out_string.include?("out_string -=> ")).must_equal false
      _(out_string.split("\n").size).must_equal instance_variables.size
    end

  end # describe "works with instance variable" do


  describe "works with class variable" do

    it "supports a single variable" do
      my_world_view = WorldView.new
      out_string = my_world_view.test_single_class_var
      assert out_string.include? "@@d -=> 4"
      _(out_string.split("\n").size).must_equal 1
    end

    it "supports multiple variables" do
      my_world_view = WorldView.new
      out_string = my_world_view.test_multiple_class_vars
      assert out_string.include? "@@d -=> 4"
      assert out_string.include? "@@e -=> 5"
      assert out_string.include? "@@f -=> 6"
      _(out_string.split("\n").size).must_equal 3
    end

    it "shows all class variables" do
      my_world_view = WorldView.new
      out_string = my_world_view.test_all_class_vars

      assert out_string.include? "@@d -=> 4"
      assert out_string.include? "@@e -=> 5"
      assert out_string.include? "@@f -=> 6"

      _(out_string.include?("out_string -=> ")).must_equal false
      _(out_string.include?("@a -=> ")).must_equal false

      _(out_string.split("\n").size).must_equal WorldView.class_variables.size
    end

  end # describe "works with class variable" do


  describe "works with CONSTANTS" do

    A,B,C = 1,2,3

    it "supports a single CONSTANT" do
      out_string = debug_me(file:nil,header:false){:A}
      assert out_string.include? "A -=> #{A}"
      _(out_string.split("\n").size).must_equal 1
    end

    it "supports multiple CONSTANTS" do
      out_string = debug_me(file:nil,header:false){[:A, :B, :C]}
      assert out_string.include? "A -=> #{A}"
      assert out_string.include? "B -=> #{B}"
      assert out_string.include? "C -=> #{C}"
      _(out_string.split("\n").size).must_equal 3
    end

  end # describe "works with CONSTANTS" do


  describe "works with class CONSTANTS" do

    before do
      @my_world_view = WorldView.new
    end

    it "supports a single class CONSTANT" do
      out_string = debug_me(file:nil,header:false){'WorldView::A'}
      assert out_string.include? "WorldView::A -=> #{WorldView::A}"
      _(out_string.split("\n").size).must_equal 1
    end

    it "supports multiple class CONSTANTS" do
      out_string = debug_me(file:nil,header:false){[
        'WorldView::A', 'WorldView::B', 'WorldView::C']}
      assert out_string.include? "WorldView::A -=> #{WorldView::A}"
      assert out_string.include? "WorldView::B -=> #{WorldView::B}"
      assert out_string.include? "WorldView::C -=> #{WorldView::C}"
      _(out_string.split("\n").size).must_equal 3
    end

    it "shows all class CONSTANTS" do
      out_string = @my_world_view.my_constants

      assert out_string.include? "A -=> #{WorldView::A}"
      assert out_string.include? "B -=> #{WorldView::B}"
      assert out_string.include? "C -=> #{WorldView::C}"
      assert out_string.include? 'MY_CONSTANT -=> "Jesus"'

      _(out_string.include?("out_string -=> ")).must_equal false
      _(out_string.include?("@d -=> ")).must_equal false

      _(out_string.split("\n").size).must_equal WorldView.constants.size
    end

  end # describe "works with class CONSTANTS" do

  describe 'non-String block values' do
    it 'prints a plain Object labeled by its class' do
      obj = Object.new
      out_string = debug_me(file: nil, time: false, header: false) { obj }
      _(out_string).must_equal "DEBUG Object -=> #{obj.pretty_inspect}"
    end

    it 'prints a value whose to_s is not a variable name' do
      path = Pathname.new('/tmp/some file.txt')
      out_string = debug_me(file: nil, time: false, header: false) { path }
      _(out_string).must_equal "DEBUG Pathname -=> #{path.pretty_inspect}"
    end

    it 'prints non-String values beside Symbols and Strings in an array' do
      @b = 2
      out_string = debug_me(file: nil, time: false, header: false) { [:@b, '@b + 1', 3.5] }
      _(out_string).must_equal "DEBUG @b -=> 2\nDEBUG @b + 1 -=> 3\nDEBUG Float -=> 3.5\n"
    end

    it 'labels a Class or Module by its name' do
      out_string = debug_me(file: nil, time: false, header: false) { [Pathname, Comparable] }
      _(out_string).must_equal "DEBUG Pathname -=> Pathname\nDEBUG Comparable -=> Comparable\n"
    end

    it 'still reports an undefined Symbol or String name' do
      out_string = debug_me(file: nil, time: false, header: false) { [:no_such_var, 'no_such_var'] }
      _(out_string).must_equal "DEBUG no_such_var -=> \"<undefined>\"\n" * 2
    end
  end

  describe "works with a Logger class" do

    it 'default logger class is nil' do
      _(DebugMeDefaultOptions[:logger]).must_be_nil
    end

    it 'works with standard ruby Logger class' do
      Dir.mktmpdir do |dir|
        logger_output_path = File.join(dir, 'logger_class_output.txt')

        logger        = Logger.new(logger_output_path)
        logger.level  = Logger::DEBUG

        out_string    = debug_me(
                                  logger: logger,         # Use instance of Ruby's Logger
                                  time:   false,          # turn off debug_me's timestamp
                                  file:   nil,            # don't write to STDOUT the default
                                  tag:    'Hello World'   # say hello
                                )
        logger.close
        # Generates an entry like this:
=begin
        # Logfile created on 2020-04-27 16:16:38 -0500 by logger.rb/v1.4.2
        D, [2020-04-27T16:16:38.580889 #54662] DEBUG -- : Hello World Source: debug_me_test.rb:244:in `block (3 levels) in <main>'
=end

        lines   = File.read(logger_output_path).split("\n")

        _(lines.size).must_equal 2

        _(lines[0].start_with?('# Logfile created on')).must_equal   true
        _(lines[1].start_with?('D, [')).must_equal                   true
        _(lines[1].include?('DEBUG')).must_equal                     true
        _(lines[1].include?('Hello World')).must_equal               true
        _(lines[1].include?('debug_me_test.rb')).must_equal          true
        _(lines[1].include?(out_string.chomp)).must_equal            true
      end
    end

  end

  describe "$DEBUG_ME global flag" do

    it 'returns nil when $DEBUG_ME is false' do
      $DEBUG_ME = false
      a = 42
      result = debug_me(file: nil, header: false) { :a }
      _(result).must_be_nil
    end

    it 'produces no output when $DEBUG_ME is false' do
      $DEBUG_ME = false
      file = StringIO.new
      log  = StringIO.new
      a = 42
      result = debug_me(file: file, logger: Logger.new(log)) { :a }
      _(result).must_be_nil
      _(file.string).must_be_empty
      _(log.string).must_be_empty
    end

    it 'works normally when $DEBUG_ME is true' do
      $DEBUG_ME = true
      a = 42
      result = debug_me(file: nil, header: false) { :a }
      _(result).wont_be_nil
      assert result.include?("a -=> 42")
    end

    it 'can be toggled on and off' do
      # Start with it on
      $DEBUG_ME = true
      a = 42
      result1 = debug_me(file: nil, header: false) { :a }
      _(result1).wont_be_nil
      assert result1.include?("a -=> 42")

      # Turn it off
      $DEBUG_ME = false
      result2 = debug_me(file: nil, header: false) { :a }
      _(result2).must_be_nil

      # Turn it back on
      $DEBUG_ME = true
      result3 = debug_me(file: nil, header: false) { :a }
      _(result3).wont_be_nil
      assert result3.include?("a -=> 42")
    end

    it 'does not evaluate the block when disabled' do
      $DEBUG_ME = false
      side_effect = false

      result = debug_me(file: nil) do
        side_effect = true  # This should not execute
        :dummy
      end

      _(result).must_be_nil
      _(side_effect).must_equal false
    end

    it 'works with all debug_me features when enabled' do
      $DEBUG_ME = true
      @instance_var = 'test'
      local_var = 'local'

      result = debug_me(file: nil, header: false) { [:@instance_var, :local_var] }

      _(result).wont_be_nil
      assert result.include?('@instance_var')
      assert result.include?('local_var')
    end

  end # describe "$DEBUG_ME global flag" do

end # describe DebugMe do
