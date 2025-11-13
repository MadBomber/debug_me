# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Updated test syntax for Minitest 6 compatibility
- Improved gemspec with proper metadata and MIT license
- Enhanced README with prominent security warning about `eval()` usage
- Enhanced README with dedicated section explaining `$DEBUG_ME` global flag usage

### Fixed
- Fixed class variable tests by moving them to proper class context
- Fixed type checking to use idiomatic `is_a?(Hash)` instead of string comparison
- Fixed typos in test descriptions ("multible" → "multiple")
- Removed commented-out dead code

### Added
- Added `DEBUG_ME_MAX_BACKTRACE` constant for magic number
- Added missing development dependencies (`amazing_print`, `minitest`)
- Added `required_ruby_version` to gemspec
- Added CHANGELOG.md file
- Added comprehensive test suite for `$DEBUG_ME` global flag (7 tests)
- Added documentation for `$DEBUG_ME` with Rails and non-Rails examples

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

[Unreleased]: https://github.com/MadBomber/debug_me/compare/v1.1.1...HEAD
[1.1.1]: https://github.com/MadBomber/debug_me/releases/tag/v1.1.1
[1.1.0]: https://github.com/MadBomber/debug_me/releases/tag/v1.1.0
[1.0.6]: https://github.com/MadBomber/debug_me/releases/tag/v1.0.6
[1.0.5]: https://github.com/MadBomber/debug_me/releases/tag/v1.0.5
[1.0.4]: https://github.com/MadBomber/debug_me/releases/tag/v1.0.4
