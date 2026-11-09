# DebugMe

<table>
<tr>
<td width="30%">
<img src="assets/debug_me.jpg" alt="DebugMe Logo"/>
</td>
<td width="70%">

<h2>A Classic Debugging Technique That Never Gets Old</h2>
<p>Printing labeled variable values to STDOUT is one of the oldest and most fundamental debugging techniques in computer science. From the earliest days of programming, developers have relied on simple output statements to understand what their code is doing. While modern debuggers offer sophisticated features like breakpoints and step-through execution, there's something elegantly simple and universally effective about printing variables to see their values in real-time.
<p>**DebugMe** embraces this time-tested approach, making it effortless to inspect local, instance, and class variables with clearly labeled output. Sometimes the old ways are the best ways.
</td>
</tr>
</table>

---

## Key Features

- **Variable Inspection** - Display labeled values of local, instance, and class variables
- **Flexible Output** - Customize tags, timestamps, headers, and output destinations
- **Global Control** - Enable/disable all debug output via `$DEBUG_ME` flag
- **Zero Overhead** - When disabled, debug blocks aren't evaluated
- **Logger Integration** - Works with Ruby's Logger and Rails.logger
- **Call Stack Support** - Optionally include backtrace information

## Quick Example

```ruby
require 'debug_me'
include DebugMe

name = "Ruby"
version = 3.2
features = [:ractors, :fiber_scheduler]

debug_me { [:name, :version, :features] }

# With a custom tag (shorthand syntax)
debug_me('INIT') { [:name, :version] }
# Equivalent to: debug_me(tag: 'INIT') { [:name, :version] }
```

**Output:**

```
2026-11-09 12:30:45.123456 DEBUG Source:  example.rb:8:in '<main>'
2026-11-09 12:30:45.123456 DEBUG name -=> "Ruby"
2026-11-09 12:30:45.123456 DEBUG version -=> 3.2
2026-11-09 12:30:45.123456 DEBUG features -=> [:ractors, :fiber_scheduler]
2026-11-09 12:30:45.123457 INIT Source:  example.rb:11:in '<main>'
2026-11-09 12:30:45.123457 INIT name -=> "Ruby"
2026-11-09 12:30:45.123457 INIT version -=> 3.2
```

## Why DebugMe?

| Feature | DebugMe | puts | debugger |
|---------|---------|------|----------|
| Labeled output | :white_check_mark: | :x: | N/A |
| Source location | :white_check_mark: | :x: | :white_check_mark: |
| Zero overhead when disabled | :white_check_mark: | :x: | :white_check_mark: |
| No code changes to disable | :white_check_mark: | :x: | :x: |
| Works in production | :white_check_mark: | :white_check_mark: | :x: |
| Timestamps | :white_check_mark: | :x: | N/A |

## Installation

```bash
gem install debug_me
```

Or add to your Gemfile:

```ruby
gem 'debug_me'
```

## Requirements

- Ruby >= 3.2.0
- No external dependencies

## License

Released under the [MIT License](https://opensource.org/licenses/MIT).

## Links

- [GitHub Repository](https://github.com/MadBomber/debug_me)
- [RubyGems Page](https://rubygems.org/gems/debug_me)
- [Changelog](changelog.md)
