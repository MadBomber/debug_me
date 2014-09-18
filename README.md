# DebugMe

This thing is pretty old.  There are much better
ways of debugging in a complex application.  But,
you know, I keep returning to this little method
time after time.  I guess that marks me as a geezer.

A tool to print the labeled value of variables.

Works with local, instance and class variables.

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

debug_me(:header => false) {} # disables the printing of the header; prints all variables

debug_me(:tag => 'MyTag', :header => false) {} # disables header, sets different tag, prints all variables

debug_me('=== LOOK ===') {} # changes the tag and prints all variables with a header line

debug_me('=== LOOK ===') {:@foo} # changes the tag, prints a header line and a specific instance variable

debug_me('=== LOOK ===') {:@@foo} # changes the tag, prints a header line and a specific class variable

debug_me(:ivar => false, :cvar => false) {} # print only the local variables with the default tag and a header line

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/debug_me/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
