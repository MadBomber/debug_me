# Getting Started

This guide will help you start using DebugMe in your Ruby projects.

## Shorthand Syntax

Before diving in, note that DebugMe supports a convenient shorthand for the `tag` option:

```ruby
# These two calls are equivalent:
debug_me(tag: 'PAYMENT') { :amount }
debug_me('PAYMENT') { :amount }
```

When the first argument is a string, it's automatically used as the tag. This shorthand works with all other options too:

```ruby
debug_me('INFO', levels: 2) { :data }
# Same as:
debug_me(tag: 'INFO', levels: 2) { :data }
```

## Basic Setup

### 1. Require and Include

```ruby
require 'debug_me'
include DebugMe
```

The `include DebugMe` statement makes the `debug_me` method available in your current scope.

!!! note "Include Options"
    You can include `DebugMe` at different levels:

    - **Top level** (global): Available everywhere in your application
    - **In a base class**: Available in that class and subclasses
    - **In specific classes**: Available only where included

    For Rails apps, set up an initializer to configure defaults once. See [Configuration](configuration.md#including-the-module) for details.

### 2. Your First Debug Statement

```ruby
name = "Alice"
age = 30

debug_me { :name }
```

**Output:**

```
2026-11-09 12:30:45.123456 DEBUG Source:  example.rb:4:in '<main>'
2026-11-09 12:30:45.123456 DEBUG name -=> "Alice"
```

## Inspecting Variables

### Single Variable

Use a symbol to inspect one variable:

```ruby
message = "Hello, World!"
debug_me { :message }
```

### Multiple Variables

Use an array of symbols for multiple variables:

```ruby
x = 10
y = 20
z = 30

debug_me { [:x, :y, :z] }
```

**Output:**

```
2026-11-09 12:30:45.123456 DEBUG Source:  example.rb:5:in '<main>'
2026-11-09 12:30:45.123456 DEBUG x -=> 10
2026-11-09 12:30:45.123456 DEBUG y -=> 20
2026-11-09 12:30:45.123456 DEBUG z -=> 30
```

### All Local Variables

Call with an empty block to show all local variables:

```ruby
first = "one"
second = "two"
third = "three"

debug_me {}
```

## Instance Variables

Prefix with `@` to inspect instance variables:

```ruby
class User
  def initialize(name)
    @name = name
    @created_at = Time.now
    debug_me { [:@name, :@created_at] }
  end
end

User.new("Bob")
```

## Class Variables

Prefix with `@@` to inspect class variables:

```ruby
class Counter
  @@count = 0

  def increment
    @@count += 1
    debug_me { :@@count }
  end
end
```

## Expressions

Pass strings to evaluate expressions:

```ruby
numbers = [1, 2, 3, 4, 5]
debug_me { 'numbers.sum' }
debug_me { 'numbers.size' }
```

**Output:**

```
2026-11-09 12:30:45.123456 DEBUG Source:  example.rb:2:in '<main>'
2026-11-09 12:30:45.123456 DEBUG numbers.sum -=> 15
2026-11-09 12:30:45.123457 DEBUG Source:  example.rb:3:in '<main>'
2026-11-09 12:30:45.123457 DEBUG numbers.size -=> 5
```

## Customizing Output

### Custom Tag

```ruby
debug_me(tag: 'INFO') { :status }
debug_me(tag: 'WARN') { :error_count }
```

### Without Header

```ruby
value = 42
debug_me(header: false) { :value }
```

**Output:**

```
2026-11-09 12:30:45.123456 DEBUG value -=> 42
```

### Without Timestamp

```ruby
debug_me(time: false) { :data }
```

## Enabling and Disabling

### Global Control

```ruby
$DEBUG_ME = false  # Disable all debug output
$DEBUG_ME = true   # Enable debug output
```

### Environment Variable

```bash
# Disable debug output
DEBUG_ME=false ruby my_script.rb

# Enable debug output
DEBUG_ME=true ruby my_script.rb
```

## Next Steps

- Learn about all [Configuration Options](configuration.md)
- See more [Usage Examples](usage.md)
- Read the [API Reference](api-reference.md)
- Review [Security Considerations](security.md)
