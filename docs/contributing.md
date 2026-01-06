# Contributing

Thank you for your interest in contributing to DebugMe! This guide will help you get started.

## Getting Started

### Prerequisites

- Ruby >= 2.3.0
- Git
- Bundler

### Setup

1. Fork the repository on GitHub
2. Clone your fork locally:

```bash
git clone https://github.com/YOUR_USERNAME/debug_me.git
cd debug_me
```

3. Install dependencies:

```bash
bundle install
```

4. Verify the tests pass:

```bash
bundle exec rake test
```

## Development Workflow

### Running Tests

```bash
# Run all tests
bundle exec rake test

# Run a specific test file
bundle exec ruby tests/debug_me_test.rb

# Run with verbose output
bundle exec ruby tests/debug_me_test.rb -v
```

### Code Style

- Follow standard Ruby conventions
- Use 2 spaces for indentation
- Keep lines under 100 characters when practical
- Add comments for complex logic

### Making Changes

1. Create a feature branch:

```bash
git checkout -b feature/your-feature-name
```

2. Make your changes
3. Add or update tests as needed
4. Ensure all tests pass
5. Commit your changes with a descriptive message

## Submitting Changes

### Pull Request Process

1. Push your branch to your fork:

```bash
git push origin feature/your-feature-name
```

2. Open a Pull Request on GitHub
3. Fill out the PR template with:
   - Description of changes
   - Motivation for the change
   - Any breaking changes
   - Test coverage

### PR Guidelines

- **One feature per PR** - Keep changes focused
- **Include tests** - All new functionality should have tests
- **Update documentation** - Update README and docs if needed
- **Follow conventions** - Match existing code style

## Types of Contributions

### Bug Reports

When filing a bug report, include:

- Ruby version (`ruby -v`)
- DebugMe version
- Operating system
- Minimal code example reproducing the issue
- Expected vs actual behavior

### Feature Requests

For new features, please describe:

- The use case
- Proposed API/interface
- Any alternatives considered

### Documentation

Documentation improvements are always welcome:

- Fix typos
- Clarify explanations
- Add examples
- Improve organization

### Code Contributions

Ideas for contributions:

- Performance improvements
- New output formats
- Additional variable types
- Better error messages
- Test coverage improvements

## Testing Guidelines

### Test Structure

Tests are located in the `tests/` directory using Minitest:

```ruby
require 'minitest/autorun'
require_relative '../lib/debug_me'

class DebugMeTest < Minitest::Test
  include DebugMe

  def test_feature
    # Arrange
    # Act
    # Assert
  end
end
```

### Writing Good Tests

- Test one behavior per test method
- Use descriptive test names
- Include edge cases
- Test both success and failure scenarios

### Test Categories

- **Source header tests** - Verify file/line output
- **Variable tests** - Local, instance, class variables
- **Option tests** - Each configuration option
- **Integration tests** - Logger, file output
- **Edge cases** - Empty blocks, nil values

## Release Process

Releases are managed by the maintainer:

1. Update version in `lib/debug_me/version.rb`
2. Update CHANGELOG.md
3. Create git tag
4. Build and push gem

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow

## Questions?

- Open a GitHub issue for questions
- Check existing issues before creating new ones
- Tag issues appropriately

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to DebugMe!
