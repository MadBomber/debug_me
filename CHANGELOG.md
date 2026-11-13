# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `DebugMe.debug_me` can be called without `include DebugMe`; the block is evaluated in the caller's context
- A documentation site at https://madbomber.github.io/debug_me/

### Changed
- The gem package now contains only `lib/`, `README.md`, `LICENSE.txt`, and `CHANGELOG.md`
- The gem now advertises its documentation site and uses an https homepage (issue #39)
- The header and `levels:` now capture only the stack frames they need instead of the whole call stack
- Minimum Ruby is now 3.2 (was 2.3); on older Rubies, pin `gem 'debug_me', '1.1.3'` (issue #17)

### Fixed
- With no variables listed, constants and class variables are now read from the receiver's class, or from the receiver itself when it is a class or module; constants still pending autoload are left out rather than loaded. `class_exec` and `Class.new(Base) { ... }` blocks no longer print them as `<undefined>`, and discovery also works when `self` is a `BasicObject` or a `Delegator` (issues #44, #45)
- A String tag can now be followed by other options, as the docs describe: `debug_me('INFO', levels: 2) { :data }` no longer raises `ArgumentError`. Keyword options can also follow a positional options Hash, and win when both set the same key
- Docs: the API reference now names `DebugMe::DEBUG_ME_VERSION` and gives `DEBUG_ME_MAX_BACKTRACE` as 10000
- `debug_me(levels: N) { :backtrace }` printed the backtrace twice; it now prints once, where the block lists it
- A String `levels:` value is now accepted: `debug_me(levels: "2") { :x }` no longer raises `ArgumentError`
- Requiring `debug_me` with warnings on (`ruby -w`, `rake test`) no longer prints `warning: global variable '$DEBUG_ME' not initialized`
- A block value that is not a Symbol or String is now printed as it is, labeled by its class name (a Class or Module by its own name): `debug_me { obj }` no longer raises `SyntaxError` when `obj.to_s` is not a variable name
- README examples corrected so each one is valid Ruby
- Docs: sample output on the documentation site now matches what `debug_me` prints, including `levels:` backtraces as `[index, frame]` pairs and a returned `:backtrace` as plain frame strings (PRs #38, #41, #47)
- `skip1:` and `skip2:` now add their blank lines when `header: false`; before, they only did so with the header on
- Only the Symbol `:backtrace` or the String `'backtrace'` asks for the call stack; any other block value whose `to_s` is `"backtrace"` (a `Pathname`, say) is printed as a value and no longer hides the `levels:` backtrace (issue #54)

### Removed
- The unused `amazing_print` development dependency, and a Ruby 1.8.6 branch for `caller` returning a String (Fixes #17)

## [1.1.2] - 2025-01-13

### Changed
- Updated test syntax for Minitest 6 compatibility
- Improved gemspec with proper metadata and MIT license
- Enhanced README with prominent security warning about `eval()` usage
- Enhanced README with dedicated section explaining `$DEBUG_ME` global flag usage
- Enhanced README with visual header image and classic debugging technique description
- `$DEBUG_ME` now initializes from `ENV['DEBUG_ME']` environment variable automatically

### Fixed
- Fixed class variable tests by moving them to proper class context
- Fixed type checking to use idiomatic `is_a?(Hash)` instead of string comparison
- Fixed typos in test descriptions ("multible" → "multiple")
- Removed commented-out dead code

### Added
- Added visual header image (debug_me.jpg) to README
- Added `DEBUG_ME_MAX_BACKTRACE` constant for magic number
- Added missing development dependencies (`amazing_print`, `minitest`)
- Added `required_ruby_version` to gemspec
- Added CHANGELOG.md file
- Added comprehensive test suite for `$DEBUG_ME` global flag (7 tests)
- Added documentation for `$DEBUG_ME` with Rails and non-Rails examples
- Added `ENV['DEBUG_ME']` environment variable support for controlling debug output
- Added environment variable tests covering all boolean value representations
- Added production deployment examples (Docker, Heroku, systemd) to README

## [1.1.1] - 2020-04-27

### Added
- Added global constant `$DEBUG_ME` as a boolean (default: true)
- When `$DEBUG_ME` is false, the `debug_me` method does nothing

## [1.1.0] - 2020-04-27

### Changed
- Changed output formatting with respect to the use of levels option

### Added
- Added `:backtrace` option for full backtrace display

## [1.0.6] - 2020-04-26

### Added
- Added support for variable backtrace length via the `:levels` option

## [1.0.5] - 2020-04-25

### Added
- Added support for an instance of a Logger class (e.g., Rails.logger)

## [1.0.4] - 2020-04-24

### Added
- Added `:strftime` option for customizable timestamp formatting

### Changed
- Changed default timestamp format from decimal seconds since epoch to human-readable clock format (`%Y-%m-%d %H:%M:%S.%6N`)

## Earlier Versions

See git history for changes in versions prior to 1.0.4.

[Unreleased]: https://github.com/MadBomber/debug_me/compare/v1.1.2...HEAD
[1.1.2]: https://github.com/MadBomber/debug_me/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/MadBomber/debug_me/releases/tag/v1.1.1
[1.1.0]: https://github.com/MadBomber/debug_me/releases/tag/v1.1.0
[1.0.6]: https://github.com/MadBomber/debug_me/releases/tag/v1.0.6
[1.0.5]: https://github.com/MadBomber/debug_me/releases/tag/v1.0.5
[1.0.4]: https://github.com/MadBomber/debug_me/releases/tag/v1.0.4
