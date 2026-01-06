# Installation

## Requirements

- Ruby >= 2.3.0
- No external dependencies

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

For development purposes, you may want to install with development dependencies:

```ruby
# Gemfile
gem 'debug_me', group: :development
```

This ensures the gem is only loaded in development environments.

## Rails Integration

For Rails applications, add to your `Gemfile`:

```ruby
group :development, :test do
  gem 'debug_me'
end
```

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
    - **No include**: Use `DebugMe.debug_me { :var }` anywhere

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
DEBUG  [2025-01-06 12:30:45.123456]  irb:3
   test_var -=> "Hello, DebugMe!"
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
