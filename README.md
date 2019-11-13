# DebugMe

A tool to print the labeled value of variables.

This thing is pretty old;but, so am I.  For the gray
in our hair we still to the job.

There are much complex/comprehensive
ways of debugging in a complex application.  But,
you know, I keep returning to this little method
time after time.  I guess that marks me as a geezer.


DebugMe::debug_me(){} works with local, instance and class variables.

## Recent Changes

* 1.0.4 Added :strftime to the options; changed the default format from decimal seconds since epic to something that os more easy comprehend on a clock.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'debug_me'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install debug_me

## Examples Usage

```ruby
require 'debug_me'
include DebugMe

debug_me # Prints only the header banner consisting of tag, method name, file name and line number

debug_me('INFO') # Also prints only the header but with a different tag

debug_me {} # prints the default header and __ALL__ variables

debug_me {:just_this_variable} # prints the default header and the value of only one specific variable

debug_me { [:this_one, :that_one, :that_other_one] } # prints default header and three specific variables

# Use an array of symbols and strings to pass multiple variables for output
# Each element of the array is 'eval'ed with the context binding of the caller
debug_me(){[ :my_var, 'my_complex_var_or_method[my_var]' ]}

debug_me(header: false) {} # disables the printing of the header; prints all variables

debug_me(tag: 'MyTag', :header => false) {} # disables header, sets different tag, prints all variables

debug_me('=== LOOK ===') {} # changes the tag and prints all variables with a header line

debug_me('=== LOOK ===') {:@foo} # changes the tag, prints a header line and a specific instance variable

debug_me('=== LOOK ===') {:@@foo} # changes the tag, prints a header line and a specific class variable

debug_me(ivar: false, cvar: false) {} # print only the local variables with the default tag and a header line

```

Most of the examples above use symbols to designate the variables that you want
to be shown with their name as a label.  You can also use strings.  With strings
you are not limited to just variables.  Consider these examples:

```ruby
debug_me {[ 'some_array.size', 'SomeDatabaseModel.count' ]}

# What a backtrace with your variables?

debug_me {[
  :my_variable,
  'some_hash.keys.reject{|k| k.to_s.start_with?('A')}',
  'caller' ]}  # yes, caller is a kernel method that will give a backtrace

# You can also get into trouble so be careful.  The symbols and strings
# are evaluated in the context of the caller.  Within the string any
# command or line of code can be given.  SO DO NOT try to use
# something silly like debug_me{ 'system("rm -fr /")'}

```

## Default Options

The default options is a global constant `DebugMeDefaultOptions` that is outside of the `DebugMe` name space.  I did that so that if you do `include DebugMe` to make access to the method easier you could still have the constant with a function specific name that would be outside of anything that you may have already coded in you program.

Notice that this constant is outside of the DebugMe's module namespace.

```
DebugMeDefaultOptions = {
  tag:    'DEBUG',  # A tag to prepend to each output line
  time:   true,     # Include a time-stamp in front of the tag
  strftime:  '%Y-%m-%d %H:%M:%S.%6N', # timestamp format
  header: true,     # Print a header string before printing the variables
  lvar:   true,     # Include local variables
  ivar:   true,     # Include instance variables in the output
  cvar:   true,     # Include class variables in the output
  cconst: true,     # Include class constants
  file:   $stdout   # The output file
}
```

If you want the output of the method to always go to STDERR then do this:

```
require 'debug_me'
DebugMeDefaultOptions[:file] = $stderr
```
If you want the `debug_me` output to go to a real file:

```
DebugMeDefaultOptions[:file] = File.open('debug_me.log', 'w')

```

The rest of the default options are obvious.

You can always over-ride the default options on a case by case basis like this:

```
debug_me {...}
...
debug_me(header: false){...}
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/debug_me/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
