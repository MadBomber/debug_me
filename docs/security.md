# Security Considerations

DebugMe uses Ruby's `eval()` function to access variables in the caller's context. This provides powerful debugging capabilities but requires careful handling.

## Understanding the Risk

!!! danger "Critical Security Warning"

    **Never pass untrusted input to `debug_me`.** The gem uses `eval()` internally, which executes arbitrary Ruby code in your application's context.

### How It Works

When you call:

```ruby
user_input = params[:data]
debug_me { user_input }  # DANGEROUS!
```

DebugMe uses `eval()` to evaluate the string in the caller's binding. If `user_input` contains malicious code, it will be executed.

### Attack Example

```ruby
# If user_input contains:
user_input = "system('rm -rf /')"

# This would execute the system command:
debug_me { user_input }  # Executes: system('rm -rf /')
```

## Safe Usage Guidelines

### Do

- Use only with hardcoded variable names
- Use symbols for variable references
- Disable in production environments
- Review code for any user input paths to `debug_me`

```ruby
# Safe: hardcoded symbols
debug_me { :my_variable }
debug_me { [:var1, :var2] }

# Safe: hardcoded strings
debug_me { 'object.method' }
```

### Don't

- Never pass user input to `debug_me`
- Never use variables containing user data as the block content
- Never use in production with debug enabled

```ruby
# DANGEROUS: user-controlled input
debug_me { params[:field] }          # Never do this!
debug_me { user.selected_field }     # Never do this!
debug_me { request.headers['X-Debug-Field'] }  # Never do this!
```

## Production Deployment

### Disable Debug Output

Always disable debug output in production:

```ruby
# config/initializers/debug_me.rb
$DEBUG_ME = false if Rails.env.production?
```

Or use environment variables:

```bash
# Production deployment
DEBUG_ME=false bundle exec rails server
```

### Docker Configuration

```dockerfile
ENV DEBUG_ME=false
```

### Heroku

```bash
heroku config:set DEBUG_ME=false
```

### Systemd Service

```ini
[Service]
Environment="DEBUG_ME=false"
```

## Code Review Checklist

When reviewing code that uses DebugMe, check for:

- [ ] No user input flows into `debug_me` blocks
- [ ] No dynamic variable names based on external data
- [ ] Production environment has `$DEBUG_ME = false`
- [ ] CI/CD pipelines set `DEBUG_ME=false` for deployments
- [ ] No `debug_me` calls in security-sensitive code paths

## Security Best Practices

### 1. Use Static Analysis

Consider adding a custom RuboCop rule to detect potentially unsafe patterns:

```ruby
# Example pattern to flag
debug_me { variable_from_user }
```

### 2. Wrap in Development Check

```ruby
def safe_debug(options = {}, &block)
  return unless Rails.env.development?
  debug_me(options, &block)
end
```

### 3. Audit Regular Expressions

Search your codebase for potentially unsafe patterns:

```bash
# Find debug_me calls with variables (potential risks)
grep -r "debug_me.*{.*[^:]" --include="*.rb" .
```

### 4. Remove Before Deployment

Consider using a pre-commit hook or CI check to warn about `debug_me` calls:

```bash
#!/bin/bash
# .git/hooks/pre-commit
if git diff --cached --name-only | xargs grep -l "debug_me" 2>/dev/null; then
  echo "Warning: debug_me calls found in staged files"
  echo "Consider removing before production deployment"
fi
```

## Comparison with Alternatives

| Method | Eval Risk | Production Safe |
|--------|-----------|-----------------|
| `debug_me` | Yes | With `$DEBUG_ME=false` |
| `puts` | No | Yes (but noisy) |
| `pp` | No | Yes |
| `Rails.logger` | No | Yes |
| `binding.pry` | Yes | No |
| `byebug` | Yes | No |

## Reporting Security Issues

If you discover a security vulnerability in DebugMe, please report it responsibly:

1. **Do not** open a public GitHub issue
2. Email the maintainer directly
3. Allow time for a fix before public disclosure

## Summary

DebugMe is safe when used correctly:

1. **Only use hardcoded variable names** (symbols or literal strings)
2. **Never pass user input** to the debug block
3. **Disable in production** via `$DEBUG_ME = false`
4. **Review code** for any paths where external data could reach `debug_me`

Treat `debug_me` with the same caution you would treat any `eval()` statement in your codebase.
