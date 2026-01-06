# Configuration

DebugMe provides extensive configuration options through the `DebugMeDefaultOptions` hash and per-call options. You can configure defaults once for your entire application, eliminating the need to pass options on every call.

## Including the Module

The `debug_me` method is defined in the `DebugMe` module. How you include it determines the method's availability:

### Without Including

Without including the module, use the fully-qualified method name:

```ruby
require 'debug_me'

DebugMe.debug_me { :my_variable }
DebugMe.debug_me('INFO', levels: 2) { :data }
```

### Include at Kernel Level (Global)

Include in `Kernel` to make `debug_me` available everywhere in your application:

```ruby
require 'debug_me'
include DebugMe  # At top level, this includes into Object/Kernel

# Now available globally
debug_me { :anywhere }
```

### Include at Application Level

In a Rails application, include in `ApplicationController` or `ApplicationRecord`:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include DebugMe
end

# Now available in all controllers
class UsersController < ApplicationController
  def show
    debug_me { :params }
  end
end
```

### Include in Specific Classes

For more targeted usage, include only where needed:

```ruby
class PaymentProcessor
  include DebugMe

  def process(amount)
    debug_me('PAYMENT') { :amount }
  end
end

class OtherClass
  # debug_me not available here unless using DebugMe.debug_me
end
```

## Application-Wide Configuration

Configure defaults once so every `debug_me` call uses your preferred settings.

### Rails Initializer

Create `config/initializers/debug_me.rb`:

```ruby
require 'debug_me'

# Include globally (optional - see "Including the Module" above)
include DebugMe

# Disable in production
$DEBUG_ME = !Rails.env.production?

# Configure defaults for all debug_me calls
DebugMeDefaultOptions[:tag]    = 'MYAPP'
DebugMeDefaultOptions[:logger] = Rails.logger
DebugMeDefaultOptions[:time]   = true
DebugMeDefaultOptions[:levels] = 0

# Or merge multiple options at once
DebugMeDefaultOptions.merge!(
  tag:    'MYAPP',
  logger: Rails.logger,
  header: true,
  time:   true
)
```

Now every `debug_me` call uses these defaults:

```ruby
# Uses tag 'MYAPP', logs to Rails.logger, etc.
debug_me { :user }

# Override specific options when needed
debug_me('PAYMENT', levels: 3) { :amount }
```

### Plain Ruby Application

Create a configuration file that's required early:

```ruby
# lib/debug_config.rb
require 'debug_me'
include DebugMe

$DEBUG_ME = ENV['DEBUG'] == 'true'

DebugMeDefaultOptions[:tag]  = 'APP'
DebugMeDefaultOptions[:time] = true
DebugMeDefaultOptions[:file] = $stderr
```

```ruby
# main.rb
require_relative 'lib/debug_config'

# debug_me is now configured and available
debug_me { :starting_up }
```

## Default Options

The gem ships with these default settings:

```ruby
DebugMeDefaultOptions = {
  tag:       'DEBUG',                    # Label prepended to output
  time:      true,                       # Include timestamp
  strftime:  '%Y-%m-%d %H:%M:%S.%6N',    # Timestamp format
  header:    true,                       # Show source file and line
  levels:    0,                          # Backtrace levels to display
  skip1:     false,                      # Skip 1 blank line before output
  skip2:     false,                      # Skip 2 blank lines before output
  lvar:      true,                       # Include local variables
  ivar:      true,                       # Include instance variables
  cvar:      true,                       # Include class variables
  cconst:    true,                       # Include class constants
  logger:    nil,                        # Logger instance
  file:      $stdout                     # Output destination
}
```

## Option Reference

### Output Control

#### `tag` (String)

The label prepended to each debug output line.

```ruby
debug_me(tag: 'INFO') { :status }
# INFO  [2025-01-06 12:30:45.123456]  example.rb:1

debug_me(tag: '>>> CHECK') { :value }
# >>> CHECK  [2025-01-06 12:30:45.123456]  example.rb:1
```

!!! tip "Shorthand Syntax"
    You can pass a string as the first argument instead of using `tag:`:

    ```ruby
    # These are equivalent:
    debug_me(tag: 'INFO') { :status }
    debug_me('INFO') { :status }

    # Shorthand with additional options:
    debug_me('TRACE', levels: 3) { :data }
    ```

#### `time` (Boolean)

Whether to include a timestamp in the output.

```ruby
debug_me(time: false) { :data }
# DEBUG  example.rb:1
#    data -=> "value"
```

#### `strftime` (String)

Format string for timestamps (uses Ruby's `strftime`).

```ruby
debug_me(strftime: '%H:%M:%S') { :now }
# DEBUG  [12:30:45]  example.rb:1

debug_me(strftime: '%Y-%m-%d') { :today }
# DEBUG  [2025-01-06]  example.rb:1
```

#### `header` (Boolean)

Whether to print the header line with source location.

```ruby
debug_me(header: false) { :value }
#    value -=> 42
```

#### `levels` (Integer)

Number of backtrace levels to include in output.

```ruby
debug_me(levels: 3) { :data }
# DEBUG  [2025-01-06 12:30:45.123456]  example.rb:1
#    caller(0) -=>
#       example.rb:1:in `method_a'
#       example.rb:10:in `method_b'
#       example.rb:20:in `method_c'
#    data -=> "value"
```

#### `skip1` / `skip2` (Boolean)

Add blank lines before output for visual separation.

```ruby
debug_me(skip1: true) { :step1 }
# (one blank line)
# DEBUG  [...]  example.rb:1

debug_me(skip2: true) { :step2 }
# (two blank lines)
# DEBUG  [...]  example.rb:1
```

### Variable Selection

These options control which variables are shown when using an empty block (`debug_me {}`):

#### `lvar` (Boolean)

Include local variables. Default: `true`

```ruby
debug_me(lvar: false) {}  # Skip local variables
```

#### `ivar` (Boolean)

Include instance variables. Default: `true`

```ruby
debug_me(ivar: false) {}  # Skip instance variables
```

#### `cvar` (Boolean)

Include class variables. Default: `true`

```ruby
debug_me(cvar: false) {}  # Skip class variables
```

#### `cconst` (Boolean)

Include class constants. Default: `true`

```ruby
debug_me(cconst: false) {}  # Skip constants
```

### Output Destination

#### `file` (IO)

The output destination. Defaults to `$stdout`.

```ruby
# Output to STDERR
debug_me(file: $stderr) { :error }

# Output to a file
log_file = File.open('debug.log', 'a')
debug_me(file: log_file) { :data }
log_file.close
```

#### `logger` (Logger)

A Ruby Logger instance for integration with logging systems.

```ruby
require 'logger'

my_logger = Logger.new('application.log')
debug_me(logger: my_logger) { :status }
```

For Rails applications:

```ruby
debug_me(logger: Rails.logger) { :request_id }
```

## Global Configuration

### Modifying Defaults

You can modify the default options globally:

```ruby
# Change default tag
DebugMeDefaultOptions[:tag] = 'TRACE'

# Disable timestamps by default
DebugMeDefaultOptions[:time] = false

# Always show 2 backtrace levels
DebugMeDefaultOptions[:levels] = 2
```

### The `$DEBUG_ME` Flag

Control all debug output globally:

```ruby
$DEBUG_ME = true   # Enable (default)
$DEBUG_ME = false  # Disable all output
```

When `$DEBUG_ME` is `false`:

- No output is produced
- The debug block is not evaluated
- Zero performance overhead

### Environment Variable

Set `DEBUG_ME` in your environment:

```bash
# Disable debug output
export DEBUG_ME=false

# Enable debug output
export DEBUG_ME=true
```

Supported values:

| Enable | Disable |
|--------|---------|
| `true` | `false` |
| `yes` | `no` |
| `on` | `off` |
| `1` | `0` |

## Configuration Patterns

### Development vs Production

```ruby
# config/initializers/debug_me.rb
if defined?(DebugMe)
  include DebugMe

  $DEBUG_ME = Rails.env.development? || Rails.env.test?

  DebugMeDefaultOptions[:logger] = Rails.logger
  DebugMeDefaultOptions[:tag] = Rails.env.upcase
end
```

### Conditional Debugging

```ruby
# Enable only for specific conditions
$DEBUG_ME = ENV['VERBOSE_DEBUG'] == 'true'
```

### Per-Module Configuration

```ruby
module PaymentProcessor
  def self.debug_options
    { tag: 'PAYMENT', levels: 2 }
  end

  def process(amount)
    debug_me(PaymentProcessor.debug_options) { [:amount] }
    # processing logic
  end
end
```
