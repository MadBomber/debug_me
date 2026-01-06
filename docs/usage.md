# Usage Examples

This page provides comprehensive examples of using DebugMe in various scenarios.

## Basic Usage

### Setup

```ruby
require 'debug_me'
include DebugMe
```

### Inspecting Local Variables

```ruby
def calculate_total(items)
  subtotal = items.sum(&:price)
  tax = subtotal * 0.08
  total = subtotal + tax

  debug_me { [:subtotal, :tax, :total] }

  total
end
```

**Output:**

```
DEBUG  [2025-01-06 12:30:45.123456]  order.rb:6
   subtotal -=> 100.0
   tax -=> 8.0
   total -=> 108.0
```

### Inspecting All Variables

Use an empty block to display all local variables:

```ruby
def process_order(order_id, customer_id)
  order = Order.find(order_id)
  customer = Customer.find(customer_id)
  status = "pending"

  debug_me {}  # Shows: order_id, customer_id, order, customer, status
end
```

## Working with Objects

### Instance Variables

```ruby
class User
  def initialize(name, email)
    @name = name
    @email = email
    @created_at = Time.now

    debug_me { [:@name, :@email, :@created_at] }
  end

  def update_email(new_email)
    @previous_email = @email
    @email = new_email

    debug_me { [:@previous_email, :@email] }
  end
end
```

### Class Variables

```ruby
class SessionManager
  @@active_sessions = 0
  @@max_sessions = 100

  def self.create_session
    @@active_sessions += 1
    debug_me { [:@@active_sessions, :@@max_sessions] }
  end
end
```

### Constants

```ruby
class ApiClient
  BASE_URL = "https://api.example.com"
  TIMEOUT = 30
  VERSION = "v2"

  def initialize
    debug_me { [:BASE_URL, :TIMEOUT, :VERSION] }
  end
end
```

## Debugging Expressions

### Method Calls

```ruby
users = User.all

debug_me { 'users.count' }
debug_me { 'users.first.name' }
debug_me { 'users.map(&:email)' }
```

### Complex Expressions

```ruby
data = { name: "Alice", scores: [85, 90, 78] }

debug_me { 'data[:name]' }
debug_me { 'data[:scores].sum / data[:scores].size.to_f' }
```

## Control Flow Debugging

### Conditional Branches

```ruby
def process_payment(amount)
  debug_me(tag: 'PAYMENT START') { [:amount] }

  if amount > 1000
    debug_me(tag: 'LARGE PAYMENT') { [:amount] }
    process_large_payment(amount)
  elsif amount > 0
    debug_me(tag: 'NORMAL PAYMENT') { [:amount] }
    process_normal_payment(amount)
  else
    debug_me(tag: 'INVALID') { [:amount] }
    raise ArgumentError, "Invalid amount"
  end
end
```

### Loop Iteration

```ruby
def process_batch(items)
  items.each_with_index do |item, index|
    debug_me(tag: "ITEM #{index}") { [:item] }
    process_item(item)
  end
end
```

## Backtrace Debugging

### Call Stack Analysis

```ruby
def method_a
  debug_me(levels: 5) { :location }
end

def method_b
  method_a
end

def method_c
  method_b
end

method_c
```

**Output:**

```
DEBUG  [2025-01-06 12:30:45.123456]  example.rb:2
   caller(0) -=>
      example.rb:2:in `method_a'
      example.rb:6:in `method_b'
      example.rb:10:in `method_c'
      example.rb:13:in `<main>'
   location -=> "here"
```

## Logger Integration

### Ruby Logger

```ruby
require 'logger'

logger = Logger.new($stdout)
logger.level = Logger::DEBUG

debug_me(logger: logger) { :important_data }
```

### Rails Logger

```ruby
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)

    debug_me(logger: Rails.logger, tag: 'ORDER') {
      [:@order, 'order_params']
    }

    if @order.save
      debug_me(logger: Rails.logger, tag: 'ORDER SAVED') { :@order }
      redirect_to @order
    else
      debug_me(logger: Rails.logger, tag: 'ORDER FAILED') {
        '@order.errors.full_messages'
      }
      render :new
    end
  end
end
```

### File Logging

```ruby
debug_log = File.open('debug.log', 'a')

debug_me(file: debug_log, tag: 'TRACE') { :data }

debug_log.close
```

## Output Customization

### Minimal Output

```ruby
# Just variable values, no header or timestamp
debug_me(header: false, time: false, tag: '') { :value }
```

**Output:**

```
   value -=> 42
```

### Verbose Output

```ruby
debug_me(
  tag: 'VERBOSE',
  time: true,
  header: true,
  levels: 3,
  skip2: true
) { [:var1, :var2] }
```

### Custom Timestamp Format

```ruby
# Short time only
debug_me(strftime: '%H:%M:%S') { :data }

# Date only
debug_me(strftime: '%Y-%m-%d') { :data }

# ISO 8601
debug_me(strftime: '%Y-%m-%dT%H:%M:%S%z') { :data }
```

## Conditional Debugging

### Environment-Based

```ruby
# In your application initializer
$DEBUG_ME = ENV['DEBUG_ME'] == 'true'

# Or based on Rails environment
$DEBUG_ME = Rails.env.development?
```

### Feature-Specific

```ruby
DEBUG_PAYMENTS = ENV['DEBUG_PAYMENTS'] == 'true'

def process_payment(amount)
  $DEBUG_ME = DEBUG_PAYMENTS
  debug_me { [:amount] }
  $DEBUG_ME = true  # Reset
end
```

### Temporary Debugging

```ruby
def troublesome_method
  original_state = $DEBUG_ME
  $DEBUG_ME = true

  # Detailed debugging here
  debug_me(levels: 10) { [:all, :the, :things] }

  $DEBUG_ME = original_state
end
```

## Real-World Patterns

### API Request Debugging

```ruby
def fetch_user(user_id)
  debug_me(tag: 'API REQUEST') { [:user_id] }

  response = http_client.get("/users/#{user_id}")

  debug_me(tag: 'API RESPONSE') {
    ['response.status', 'response.body']
  }

  JSON.parse(response.body)
end
```

### Database Query Debugging

```ruby
def find_orders(customer_id, status)
  debug_me(tag: 'QUERY PARAMS') { [:customer_id, :status] }

  orders = Order.where(customer_id: customer_id, status: status)

  debug_me(tag: 'QUERY RESULT') {
    ['orders.count', 'orders.to_sql']
  }

  orders
end
```

### Background Job Debugging

```ruby
class ProcessOrderJob < ApplicationJob
  def perform(order_id)
    debug_me(tag: 'JOB START', logger: Rails.logger) { [:order_id] }

    order = Order.find(order_id)
    debug_me(tag: 'ORDER LOADED') { [:order] }

    result = process(order)
    debug_me(tag: 'JOB COMPLETE') { [:result] }

    result
  end
end
```

### Middleware Debugging

```ruby
class DebugMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request_id = env['HTTP_X_REQUEST_ID']
    path = env['PATH_INFO']

    debug_me(tag: 'REQUEST') { [:request_id, :path] }

    status, headers, body = @app.call(env)

    debug_me(tag: 'RESPONSE') { [:request_id, :status] }

    [status, headers, body]
  end
end
```
