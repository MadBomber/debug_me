#!/usr/bin/env ruby

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
      out_string.split("\n").size.must_equal 1
    end

    it "supports multible variables" do
      a,b,c = 1,2,3
      out_string = debug_me(file:nil,header:false){[:a, :b, :c]}
      assert out_string.include? "a -=> #{a}"
      assert out_string.include? "b -=> #{b}"
      assert out_string.include? "c -=> #{c}"
      out_string.split("\n").size.must_equal 3
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

      out_string.split("\n").size.must_equal 4
    end

  end # describe "works with local variable" do

  describe "works with instance variable" do

    it "supports a single variable" do
      @a,@b,@c = 1,2,3
      out_string = debug_me(file:nil,header:false){:@a}
      assert out_string.include? "@a -=> #{@a}"
      out_string.split("\n").size.must_equal 1
    end

    it "supports multible variables" do
      @a,@b,@c = 1,2,3
      out_string = debug_me(file:nil,header:false){[:@a, :@b, :@c]}
      assert out_string.include? "@a -=> #{@a}"
      assert out_string.include? "@b -=> #{@b}"
      assert out_string.include? "@c -=> #{@c}"
      out_string.split("\n").size.must_equal 3
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

      out_string.include?("out_string -=> ").must_equal false
      out_string.split("\n").size.must_equal instance_variables.size
    end

  end # describe "works with instance variable" do


  describe "works with class variable" do

    it "supports a single variable" do
      @@a,@@b,@@c = 1,2,3
      out_string = debug_me(file:nil,header:false){:@@a}
      assert out_string.include? "@@a -=> #{@@a}"
      out_string.split("\n").size.must_equal 1
    end

    it "supports multible variables" do
      @@a,@@b,@@c = 1,2,3
      out_string = debug_me(file:nil,header:false){[:@@a, :@@b, :@@c]}
      assert out_string.include? "@@a -=> #{@@a}"
      assert out_string.include? "@@b -=> #{@@b}"
      assert out_string.include? "@@c -=> #{@@c}"
      out_string.split("\n").size.must_equal 3
    end

    it "shows all class variables" do
      @@a,@@b,@@c = 1,2,3
      @d = 4
      out_string = debug_me(
        file:nil,
        header:false,
        lvar: false,
        ivar: false,
        cvar: true,
        cconst: false
        ){}

      assert out_string.include? "@@a -=> #{@@a}"
      assert out_string.include? "@@b -=> #{@@b}"
      assert out_string.include? "@@c -=> #{@@c}"

      out_string.include?("out_string -=> ").must_equal false
      out_string.include?("@d -=> ").must_equal false

      out_string.split("\n").size.must_equal self.class.class_variables.size
    end

  end # describe "works with class variable" do


  describe "works with CONSTANTS" do

    it "supports a single CONSTANT" do
      A,B,C = 1,2,3
      out_string = debug_me(file:nil,header:false){:A}
      assert out_string.include? "A -=> #{A}"
      out_string.split("\n").size.must_equal 1
    end

    it "supports multible CONSTANTS" do
      A,B,C = 1,2,3
      out_string = debug_me(file:nil,header:false){[:A, :B, :C]}
      assert out_string.include? "A -=> #{A}"
      assert out_string.include? "B -=> #{B}"
      assert out_string.include? "C -=> #{C}"
      out_string.split("\n").size.must_equal 3
    end

  end # describe "works with CONSTANTS" do


  describe "works with class CONSTANTS" do

    before do
      @my_world_view = WorldView.new
    end

    it "supports a single class CONSTANT" do
      out_string = debug_me(file:nil,header:false){'WorldView::A'}
      assert out_string.include? "WorldView::A -=> #{WorldView::A}"
      out_string.split("\n").size.must_equal 1
    end

    it "supports multible class CONSTANTS" do
      out_string = debug_me(file:nil,header:false){[
        'WorldView::A', 'WorldView::B', 'WorldView::C']}
      assert out_string.include? "WorldView::A -=> #{WorldView::A}"
      assert out_string.include? "WorldView::B -=> #{WorldView::B}"
      assert out_string.include? "WorldView::C -=> #{WorldView::C}"
      out_string.split("\n").size.must_equal 3
    end

    it "shows all class CONSTANTS" do
      out_string = @my_world_view.my_constants

      assert out_string.include? "A -=> #{WorldView::A}"
      assert out_string.include? "B -=> #{WorldView::B}"
      assert out_string.include? "C -=> #{WorldView::C}"
      assert out_string.include? 'MY_CONSTANT -=> "Jesus"'

      out_string.include?("out_string -=> ").must_equal false
      out_string.include?("@d -=> ").must_equal false

      out_string.split("\n").size.must_equal WorldView.constants.size
    end

  end # describe "works with class CONSTANTS" do



end # describe DebugMe do
