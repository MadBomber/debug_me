# DebugMe

A tool to print the labeled value of variables.

This thing is pretty old; but, so am I.  Even with the gray
in our hair we still do the job.

There are much more complex/comprehensive
ways of debugging in a complex application.  But,
you know, I keep returning to this little method
time after time.  I guess that marks me as a geezer.


DebugMe::debug_me(){} works with local, instance and class variables.

## Recent Changes

* 1.1.0 Changes the output formatting w/r/t the use of levels option; add :backtrace option for full backtrace
* 1.0.6 Added support for variable backtrack length via the :levels option
* 1.0.5 Added support for an instance of a Logger class.
* 1.0.4 Added :strftime to the options; changed the default format from decimal seconds since epic to something that is more easy comprehend on a clock.

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

debug_me(levels: 5) # Along with the header, show the call stack back this many levels
debug_me{:backtrace}          # show the entire call stack
debug_me{[ :backtrace ]} will # show the entire call stack
debug_me(levels: 5){[ :backtrace ]} # will only show the first 5 levels of the backtrace - ie. the levels parameter supersedes :backtrace

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

```ruby
DebugMeDefaultOptions = {
  tag:    'DEBUG',  # A tag to prepend to each output line
  time:   true,     # Include a time-stamp in front of the tag
  strftime:  '%Y-%m-%d %H:%M:%S.%6N', # timestamp format
  header: true,     # Print a header string before printing the variables
  levels: 0,        # Number of additional backtrack entries to display
  skip1:  false,    # skip 1 blank line in front of a new output block
  skip2:  false,    # skip 2 blank lines in front of a new output block
  lvar:   true,     # Include local variables
  ivar:   true,     # Include instance variables in the output
  cvar:   true,     # Include class variables in the output
  cconst: true,     # Include class constants
  logger: nil,      # Pass in a logger class instance like Rails.logger
  file:   $stdout   # The output file
}
```

If you want the output of the method to always go to STDERR then do this:

```ruby
require 'debug_me'
DebugMeDefaultOptions[:file] = $stderr  # or STDERR
```
If you want the `debug_me` output to go to a real file:

```ruby
DebugMeDefaultOptions[:file] = File.open('debug_me.log', 'w')

```

## Using a Logger class instance

If you are working in Rails and want all the `debug_me` output to go to the Rails.logger its as easy as:
```ruby
DebugMeDefaultOptions[:logger] = Rails.logger

```

Or while working in rails you only want to add a marker to the Rails.logger do this:
```ruby
debug_me(logger: Rails.logger, tag: 'Hello World')
```

If you are working in Rails and want to use both the standard `debug_me` functions and occassionally put stuff into the Rails.logger but do not want to always remember the option settings then do something line this in a `config/initializers/aaaaa_debug_me.rb` file:

```ruby
# config/initializers/aaaaa_debug_me.rb

require 'debug_me'

module DebugMe
  def log_me(message, options={}, &block)
    options = {logger: Rails.logger, time: false, header: false, tag: message}
    block_given? ? debug_me(options, block) : debug_me(options)
  end
end

include DebugMe

# Just setup the base name.  The parent path will be added below ...
debug_me_file_name  = 'debug_me'

# NOTE: you could add a timestamp to the filename
# debug_me_file_name += '_' + Time.now.strftime('%Y%m%d%H%M%S')

debug_me_file_name += '_' + Process.argv0.gsub('/',' ').split(' ').last
# NOTE: by using the Process.argv0 ... you get multiple log files for
#       rails, rake, sidekiq etc.

debug_me_file_name += '.log'

debug_me_filepath = Rails.root + 'log' + debug_me_file_name

debug_me_file = File.open(debug_me_filepath, 'w')

debug_me_file.puts <<~RULER

  ==================== Starting New Test Run --------->>>>>>

RULER

# Set application wide options in the DebugMeDefaultOptions hash
DebugMeDefaultOptions[:file] = debug_me_file

debug_me{['ENV']}

```

What that does for your Rails application is dump all of your system environment variables and their values to a debug_me log file in the log directory of the application.

It also adds a new method `log_me` which you can use to send stuff to the `Rails.logger` instance.  The method used by `debug_me` for the `logger` instance is always the `debug` method.

## Conclusion

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
