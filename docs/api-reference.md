# API Reference

## Module: DebugMe

The main module providing debugging functionality.

### Including the Module

```ruby
require 'debug_me'
include DebugMe
```

After including, the `debug_me` method becomes available in the current scope.

---

## Method: debug_me

```ruby
debug_me(options = {}, &block) → String | nil
debug_me(tag, options = {}, &block) → String | nil
```

The primary debugging method. Outputs labeled variable values to the configured destination.

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tag` | String | (Optional) Shorthand for `tag:` option |
| `options` | Hash | Configuration options (see below) |
| `&block` | Block | Block yielding variable names to inspect |

### Shorthand Syntax

When the first argument is a string, it's used as the `tag` option:

```ruby
# These calls are equivalent:
debug_me(tag: 'INFO') { :status }
debug_me('INFO') { :status }

# Shorthand with additional options:
debug_me('TRACE', levels: 2, time: false) { :data }
# Same as:
debug_me(tag: 'TRACE', levels: 2, time: false) { :data }
```

### Options Hash

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `tag` | String | `'DEBUG'` | Label prepended to output |
| `time` | Boolean | `true` | Include timestamp |
| `strftime` | String | `'%Y-%m-%d %H:%M:%S.%6N'` | Timestamp format |
| `header` | Boolean | `true` | Show source file and line number |
| `levels` | Integer | `0` | Number of backtrace levels to include |
| `skip1` | Boolean | `false` | Add one blank line before output |
| `skip2` | Boolean | `false` | Add two blank lines before output |
| `lvar` | Boolean | `true` | Include local variables (empty block) |
| `ivar` | Boolean | `true` | Include instance variables (empty block) |
| `cvar` | Boolean | `true` | Include class variables (empty block) |
| `cconst` | Boolean | `true` | Include constants (empty block) |
| `logger` | Logger | `nil` | Logger instance for output |
| `file` | IO | `$stdout` | Output destination |

### Block Syntax

The block should yield one of:

| Yield Type | Example | Description |
|------------|---------|-------------|
| Symbol | `{ :variable }` | Single variable name |
| Array of Symbols | `{ [:var1, :var2] }` | Multiple variable names |
| String | `{ 'expression' }` | Expression to evaluate |
| Array of Strings | `{ ['expr1', 'expr2'] }` | Multiple expressions |
| Empty | `{}` | All variables in scope |

### Return Value

Returns the output string if `$DEBUG_ME` is `true`, otherwise returns `nil`.

### Examples

```ruby
# Single variable
name = "Alice"
debug_me { :name }

# Multiple variables
x, y = 10, 20
debug_me { [:x, :y] }

# Instance variables
debug_me { [:@user, :@session] }

# Class variables
debug_me { [:@@counter] }

# Expressions
debug_me { 'array.size' }
debug_me { ['hash.keys', 'hash.values'] }

# All local variables
debug_me {}

# With options
debug_me(tag: 'INFO', levels: 2) { :data }
```

---

## Global Variable: $DEBUG_ME

```ruby
$DEBUG_ME → Boolean
```

Controls whether debug output is enabled globally.

### Values

| Value | Effect |
|-------|--------|
| `true` | Debug output is enabled (default) |
| `false` | All debug output is suppressed |

### Behavior When Disabled

When `$DEBUG_ME` is `false`:

- `debug_me` returns immediately
- The block is not evaluated
- No output is produced
- Zero performance overhead

### Example

```ruby
$DEBUG_ME = true
debug_me { :value }  # Outputs debug information

$DEBUG_ME = false
debug_me { :value }  # No output, block not evaluated
```

---

## Environment Variable: DEBUG_ME

Controls the initial value of `$DEBUG_ME` at load time.

### Supported Values

| Enable Values | Disable Values |
|---------------|----------------|
| `true` | `false` |
| `yes` | `no` |
| `on` | `off` |
| `1` | `0` |

### Usage

```bash
# Enable debug output
DEBUG_ME=true ruby script.rb

# Disable debug output
DEBUG_ME=false ruby script.rb
```

---

## Constant: DebugMeDefaultOptions

```ruby
DebugMeDefaultOptions → Hash
```

The default options hash used when options are not specified.

### Default Values

```ruby
DebugMeDefaultOptions = {
  tag:       'DEBUG',
  time:      true,
  strftime:  '%Y-%m-%d %H:%M:%S.%6N',
  header:    true,
  levels:    0,
  skip1:     false,
  skip2:     false,
  lvar:      true,
  ivar:      true,
  cvar:      true,
  cconst:    true,
  logger:    nil,
  file:      $stdout
}
```

### Modifying Defaults

```ruby
# Change default tag
DebugMeDefaultOptions[:tag] = 'TRACE'

# Disable timestamps by default
DebugMeDefaultOptions[:time] = false
```

---

## Constant: DEBUG_ME_MAX_BACKTRACE

```ruby
DEBUG_ME_MAX_BACKTRACE → Integer
```

Maximum number of backtrace levels that can be displayed. Default: `15`

---

## Output Format

### Standard Output

```
TAG  [TIMESTAMP]  SOURCE_FILE:LINE_NUMBER
   variable_name -=> value
```

### With Backtrace

```
TAG  [TIMESTAMP]  SOURCE_FILE:LINE_NUMBER
   caller(0) -=>
      file1.rb:10:in `method_a'
      file2.rb:20:in `method_b'
   variable_name -=> value
```

### Multiple Variables

```
TAG  [TIMESTAMP]  SOURCE_FILE:LINE_NUMBER
   var1 -=> value1
   var2 -=> value2
   var3 -=> value3
```

---

## Version Information

```ruby
require 'debug_me/version'
DebugMe::VERSION  # => "1.1.4"
```
