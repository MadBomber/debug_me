# Installation

## Requirements

- Ruby >= 3.2.0
- No external dependencies

On Ruby older than 3.2, use 1.1.3: `gem install debug_me -v 1.1.3`, or `gem 'debug_me', '1.1.3'` in a Gemfile.

## Installing via RubyGems

Install directly from RubyGems:

```bash
gem install debug_me
```

## Installing via Bundler

Add this line to your application's `Gemfile`:

```ruby
gem 'debug_me'
```

Then execute:

```bash
bundle install
```

## Development Installation

To install the gem only in development, put it in Bundler's `development` group:

```ruby
# Gemfile
gem 'debug_me', group: :development
```

Bundler then skips the gem wherever the `development` group is excluded, so any code that calls `debug_me` or requires the gem must not run there.

## Rails Integration

For Rails applications, add to your `Gemfile` outside any group, so the gem loads in every environment, including production:

```ruby
gem 'debug_me'
```

The initializer below requires the gem unconditionally and turns output off in production, so `debug_me` calls left in application code stay harmless there.

Create an initializer at `config/initializers/debug_me.rb`:

```ruby
require 'debug_me'

# Include globally so debug_me is available everywhere
include DebugMe

# Disable in production
$DEBUG_ME = !Rails.env.production?

# Configure defaults for your application
DebugMeDefaultOptions.merge!(
  tag:    Rails.application.class.module_parent_name.upcase,
  logger: Rails.logger,
  time:   true
)
```

!!! tip "Include Strategies"
    You have several options for including the module:

    - **Global** (shown above): `include DebugMe` at top level makes `debug_me` available everywhere
    - **Controllers only**: Include in `ApplicationController`
    - **Models only**: Include in `ApplicationRecord`
    - **Specific classes**: Include only where needed

    See [Configuration](configuration.md#including-the-module) for detailed examples.

## Verifying Installation

After installation, verify it works:

```ruby
require 'debug_me'
include DebugMe

test_var = "Hello, DebugMe!"
debug_me { :test_var }
```

You should see output similar to:

```
2026-11-09 12:30:45.123456 DEBUG Source:  example.rb:5:in '<main>'
2026-11-09 12:30:45.123456 DEBUG test_var -=> "Hello, DebugMe!"
```

## Updating

To update to the latest version:

```bash
# Using gem
gem update debug_me

# Using bundler
bundle update debug_me
```

## Uninstalling

```bash
gem uninstall debug_me
```
