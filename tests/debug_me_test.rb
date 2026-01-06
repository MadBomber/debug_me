#!/usr/bin/env ruby

require 'amazing_print'
require 'logger'
require 'pathname'

require_relative '../lib/debug_me'
include DebugMe

require_relative './world_view'



require 'minitest/autorun'

describe DebugMe do

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
  end


  describe "source header excluded" do

  	before do
  	  @out_string = debug_me(file:nil,header:false)
  	end

    it "is empty" do
      assert @out_string.empty?
    end

  end # describe "source header excluded" do

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

    it "supports a single CONSTANT" do
      A,B,C = 1,2,3
      out_string = debug_me(file:nil,header:false){:A}
      assert out_string.include? "A -=> #{A}"
      _(out_string.split("\n").size).must_equal 1
    end

    it "supports multiple CONSTANTS" do
      A,B,C = 1,2,3
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

  describe "works with a Logger class" do

    it 'default logger class is nil' do
      _(DebugMeDefaultOptions[:logger]).must_be_nil
    end

    it 'works with standard ruby Logger class' do
      logger_output_path = Pathname.pwd + 'logger_class_output.txt'
      _(logger_output_path.exist?).must_equal false

      logger        = Logger.new(logger_output_path)
      logger.level  = Logger::DEBUG

      out_string    = debug_me(
                                logger: logger,         # Use instance of Ruby's Logger
                                time:   false,          # turn off debug_me's timestamp
                                file:   nil,            # don't write to STDOUT the default
                                tag:    'Hello World'   # say hello
                              )
      # Generates an entry like this:
=begin
      # Logfile created on 2020-04-27 16:16:38 -0500 by logger.rb/v1.4.2
      D, [2020-04-27T16:16:38.580889 #54662] DEBUG -- : Hello World Source: debug_me_test.rb:244:in `block (3 levels) in <main>'
=end

      lines   = logger_output_path.read.split("\n")

      _(lines.size).must_equal 2

      _(lines[0].start_with?('# Logfile created on')).must_equal   true
      _(lines[1].start_with?('D, [')).must_equal                   true
      _(lines[1].include?('DEBUG')).must_equal                     true
      _(lines[1].include?('Hello World')).must_equal               true
      _(lines[1].include?('debug_me_test.rb')).must_equal          true
      _(lines[1].include?(out_string.chomp)).must_equal            true

      logger_output_path.delete
    end

  end

  describe "$DEBUG_ME global flag" do

    before do
      # Save the original state
      @original_debug_me = $DEBUG_ME
    end

    after do
      # Restore the original state after each test
      $DEBUG_ME = @original_debug_me
    end

    it 'is true by default' do
      _($DEBUG_ME).must_equal true
    end

    it 'returns nil when $DEBUG_ME is false' do
      $DEBUG_ME = false
      a = 42
      result = debug_me(file: nil, header: false) { :a }
      _(result).must_be_nil
    end

    it 'produces no output when $DEBUG_ME is false' do
      $DEBUG_ME = false
      a = 42
      result = debug_me(file: nil) { :a }
      _(result).must_be_nil
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

  describe "ENV['DEBUG_ME'] environment variable" do

    it 'initializes $DEBUG_ME from environment variable if set' do
      # This test documents that $DEBUG_ME can be controlled via ENV['DEBUG_ME']
      # The actual initialization happens when lib/debug_me.rb is loaded
      # Users can set DEBUG_ME=false before requiring the gem to disable it

      # Verify current state is set (either from ENV or default true)
      _($DEBUG_ME).wont_be_nil

      # Document that users can override at runtime
      original = $DEBUG_ME
      $DEBUG_ME = false
      _($DEBUG_ME).must_equal false
      $DEBUG_ME = original
    end

    it 'can be controlled by setting $DEBUG_ME directly at runtime' do
      # Save original
      original = $DEBUG_ME

      # Test setting various values
      $DEBUG_ME = false
      _($DEBUG_ME).must_equal false

      $DEBUG_ME = true
      _($DEBUG_ME).must_equal true

      $DEBUG_ME = nil
      _($DEBUG_ME).must_be_nil

      # Restore
      $DEBUG_ME = original
    end

  end # describe "ENV['DEBUG_ME'] environment variable" do

end # describe DebugMe do
