# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.4] - Unreleased

### Changed
- Version bump

## [1.1.3] - 2025-01-14

### Changed
- Version bump for release

## [1.1.2] - 2025-01-13

### Added
- Support for `DEBUG_ME` environment variable to control `$DEBUG_ME` flag
- `DEBUG_ME_MAX_BACKTRACE` constant to limit backtrace depth
- Comprehensive test coverage (24+ tests)
- Production deployment examples for Docker, Heroku, and systemd
- Security warnings and best practices documentation

### Changed
- Updated test syntax for Minitest 6 compatibility
- Improved gemspec with proper metadata and MIT license specification
- Enhanced README with quick-start guide and visual header

### Fixed
- Class variable test context
- Type checking now uses idiomatic `is_a?(Hash)` instead of `kind_of?`

## [1.1.1] - 2024-12-15

### Changed
- Minor documentation improvements
- Code cleanup

## [1.1.0] - 2024-11-01

### Added
- Logger integration support
- Configurable output destinations

### Changed
- Improved output formatting with `pretty_inspect`

## [1.0.0] - 2024-01-01

### Added
- Stable release
- Full documentation
- Comprehensive test suite

### Changed
- Finalized API

## [0.9.0] - 2023-06-01

### Added
- `$DEBUG_ME` global flag for enabling/disabling output
- Zero-overhead when disabled (block not evaluated)

### Changed
- Performance improvements

## [0.8.0] - 2022-01-01

### Added
- Backtrace support with `levels` option
- `skip1` and `skip2` options for visual separation

## [0.7.0] - 2021-01-01

### Added
- Instance variable support (`@var`)
- Class variable support (`@@var`)
- Constant support

## [0.6.0] - 2020-01-01

### Added
- Multiple variable support via arrays
- Expression evaluation via strings

## [0.5.0] - 2019-01-01

### Added
- Customizable timestamp format via `strftime`
- Header toggle option

## [0.4.0] - 2018-01-01

### Added
- Custom tag support
- Timestamp option

## [0.3.0] - 2017-01-01

### Added
- Output to custom file handles
- STDERR support

## [0.2.0] - 2016-06-01

### Added
- Source file and line number in output
- Multiple output options

## [0.1.0] - 2016-01-01

### Added
- Initial release
- Basic variable inspection
- Simple output to STDOUT
