class WorldView
  MY_CONSTANT = 'Jesus'
  A = 1
  B = 2
  C = 3

  def initialize
    @a,@b,@c       = 1,2,3
    @@d, @@e, @@f   = 4,5,6
  end

  def everything
    debug_me(
      file:   nil,
      header: true,
      lvar:   true,
      ivar:   true,
      cvar:   true,
      cconst: true
    ){}
  end

  def my_constants
    debug_me(
      file:nil,
      header:false,
      lvar: false,
      ivar: false,
      cvar: false,
      cconst: true
    ){}
  end

  def one;    two;    end
  def two;    three;  end
  def three;  four;   end
  def four;   five;   end
  def five;   six;    end

  def six
    debug_me(tag:'How did I get here?', levels: 5)
  end
end # class WorldView
