# Hati JSON:API Error

[![Gem Version](https://badge.fury.io/rb/hati-jsonapi-error.svg)](https://badge.fury.io/rb/hati-jsonapi-error)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.0.0-ruby.svg)](https://ruby-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Test Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)](https://github.com/hackico-ai/ruby-hati-jsonapi-error)

> **Production-ready JSON:API-compliant error responses for professional Web APIs**

Transform inconsistent error handling into standardized, traceable responses. Built for Ruby applications requiring enterprise-grade error management.

## Table of Contents

- [Why Standardized Error Handling Matters](#why-standardized-error-handling-matters)
  - [The Problem: Inconsistent Error Responses](#the-problem-inconsistent-error-responses)
  - [The Impact](#the-impact)
  - [The Solution: JSON:API Standard](#the-solution-jsonapi-standard)
- [✨ Features](#-features)
- [Installation](#installation)
- [Quick Start](#quick-start)
  - [1. Configuration](#1-configuration)
  - [2. Basic Usage](#2-basic-usage)
- [Usage Examples](#usage-examples)
  - [Basic Error Handling](#basic-error-handling)
  - [Rich Error Context](#rich-error-context)
  - [Multiple Validation Errors](#multiple-validation-errors)
- [Controller Integration](#controller-integration)
  - [Custom Error Classes](#custom-error-classes)
- [Functional Programming Integration](#functional-programming-integration)
- [Configuration](#configuration)
  - [Error Mapping](#error-mapping)
- [Available Error Classes](#available-error-classes)
- [Testing](#testing)
  - [RSpec Integration](#rspec-integration)
  - [Unit Testing](#unit-testing)
- [Benefits](#benefits)
- [Contributing](#contributing)
- [License](#license)

## Why Standardized Error Handling Matters

### The Problem: Inconsistent Error Responses

Different controllers returning different error formats creates maintenance nightmares:

```ruby
# Three different error formats in one application
class UsersController
  def show
    render json: { error: "User not found" }, status: 404
  end
end

class OrdersController
  def create
    render json: { message: "Validation failed", details: errors }, status: 422
  end
end

class PaymentsController
  def process
    render json: { errors: errors, error_code: "INVALID", status: "failure" }, status: 400
  end
end
```

This forces frontend developers to handle multiple error formats:

```javascript
// Unmaintainable error handling
if (data.error) {
  showError(data.error); // Users format
} else if (data.message && data.details) {
  showError(`${data.message}: ${data.details.join(", ")}`); // Orders format
} else if (data.errors && data.error_code) {
  showError(`${data.error_code}: ${data.errors.join(", ")}`); // Payments format
}
```

### The Impact

- **API Documentation**: Each endpoint needs custom error documentation
- **Error Tracking**: Different structures break centralized logging
- **Client SDKs**: Cannot provide consistent error handling
- **Testing**: Each format requires separate test cases
- **Team Coordination**: New developers must learn multiple patterns

### The Solution: JSON:API Standard

**One format across all endpoints:**

```ruby
raise HatiJsonapiError::UnprocessableEntity.new(
  detail: "Email address is required",
  source: { pointer: "/data/attributes/email" }
)
```

**Always produces standardized output:**

```json
{
  "errors": [
    {
      "status": 422,
      "code": "unprocessable_entity",
      "title": "Validation Failed",
      "detail": "Email address is required",
      "source": { "pointer": "/data/attributes/email" }
    }
  ]
}
```

## ✨ Features

- **JSON:API Compliant** - Follows the official [JSON:API error specification](https://jsonapi.org/format/#errors)
- **Auto-Generated Error Classes** - Dynamic HTTP status code error classes (400-511)
- **Rich Error Context** - Support for `id`, `code`, `title`, `detail`, `status`, `meta`, `links`, `source`
- **Error Registry** - Map custom exceptions to standardized responses
- **Controller Integration** - Helper methods for Rails, Sinatra, and other frameworks
- **100% Test Coverage** - Comprehensive RSpec test suite
- **Zero Dependencies** - Lightweight and fast
- **Production Ready** - Thread-safe and memory efficient

## Installation

```ruby
# Gemfile
gem 'hati-jsonapi-error'
```

```bash
bundle install
```

## Quick Start

### 1. Configuration

```ruby
# config/initializers/hati_jsonapi_error.rb
HatiJsonapiError::Config.configure do |config|
  config.load_errors!

  config.map_errors = {
    ActiveRecord::RecordNotFound => :not_found,
    ActiveRecord::RecordInvalid   => :unprocessable_entity,
    ArgumentError                 => :bad_request
  }

  config.use_unexpected = HatiJsonapiError::InternalServerError
end
```

### 2. Basic Usage

```ruby
# Simple error raising
raise HatiJsonapiError::NotFound.new
raise HatiJsonapiError::BadRequest.new
raise HatiJsonapiError::Unauthorized.new
```

## Usage Examples

### Basic Error Handling

**Access errors multiple ways:**

```ruby
# By class name
raise HatiJsonapiError::NotFound.new

# By status code
api_err = HatiJsonapiError::Helpers::ApiErr
raise api_err[404]

# By error code
raise api_err[:not_found]
```

### Rich Error Context

**Add debugging information:**

```ruby
HatiJsonapiError::NotFound.new(
  id: 'user_lookup_failed',
  detail: 'User with email john@example.com was not found',
  source: { pointer: '/data/attributes/email' },
  meta: {
    searched_email: 'john@example.com',
    suggestion: 'Verify the email address is correct'
  }
)
```

### Multiple Validation Errors

**Collect and return multiple errors:**

```ruby
errors = []
errors << HatiJsonapiError::UnprocessableEntity.new(
  detail: "Email format is invalid",
  source: { pointer: '/data/attributes/email' }
)
errors << HatiJsonapiError::UnprocessableEntity.new(
  detail: "Password too short",
  source: { pointer: '/data/attributes/password' }
)

resolver = HatiJsonapiError::Resolver.new(errors)
render json: resolver.to_json, status: resolver.status
```

## Controller Integration

```ruby
class ApiController < ApplicationController
  include HatiJsonapiError::Helpers

  rescue_from StandardError, with: :handle_error

  def show
    # ActiveRecord::RecordNotFound automatically mapped to JSON:API NotFound
    user = User.find(params[:id])
    render json: user
  end

  def create
    user = User.new(user_params)

    unless user.save
      validation_error = HatiJsonapiError::UnprocessableEntity.new(
        detail: user.errors.full_messages.join(', '),
        source: { pointer: '/data/attributes' },
        meta: { validation_errors: user.errors.messages }
      )

      return render_error(validation_error)
    end

    render json: user, status: :created
  end
end
```

### Custom Error Classes

**Domain-specific errors:**

```ruby
class PaymentRequiredError < HatiJsonapiError::PaymentRequired
  def initialize(amount:, currency: 'USD')
    super(
      detail: "Payment of #{amount} #{currency} required",
      meta: {
        required_amount: amount,
        currency: currency,
        payment_methods: ['credit_card', 'paypal']
      },
      links: {
        payment_page: "https://app.com/billing/upgrade?amount=#{amount}"
      }
    )
  end
end

# Usage
raise PaymentRequiredError.new(amount: 29.99)
```

## Functional Programming Integration

Perfect for functional programming patterns with [hati-operation gem](https://github.com/hackico-ai/ruby-hati-operation):

```ruby
require 'hati_operation'

class Api::User::CreateOperation < Hati::Operation
  ApiErr = HatiJsonapiError::Helpers::ApiErr

  def call(params)
    user_params = step validate_params(params), err: ApiErr[422]
    user = step create_user(user_params),       err: ApiErr[409]
    profile = step create_profile(user),        err: ApiErr[503]

    Success(profile)
  end

  private

  def validate_params(params)
    return Failure('Invalid parameters') unless params[:name]
    Success(params)
  end
end
```

## Configuration

### Error Mapping

```ruby
HatiJsonapiError::Config.configure do |config|
  config.map_errors = {
    # Rails exceptions
    ActiveRecord::RecordNotFound  => :not_found,
    ActiveRecord::RecordInvalid   => :unprocessable_entity,

    # Custom exceptions
    AuthenticationError           => :unauthorized,
    RateLimitError               => :too_many_requests,

    # Infrastructure exceptions
    Redis::TimeoutError          => :service_unavailable,
    Net::ReadTimeout             => :gateway_timeout
  }

  config.use_unexpected = HatiJsonapiError::InternalServerError
end
```

## Available Error Classes

**Quick Reference - Most Common:**

| Status | Class                 | Code                    |
| ------ | --------------------- | ----------------------- |
| 400    | `BadRequest`          | `bad_request`           |
| 401    | `Unauthorized`        | `unauthorized`          |
| 403    | `Forbidden`           | `forbidden`             |
| 404    | `NotFound`            | `not_found`             |
| 422    | `UnprocessableEntity` | `unprocessable_entity`  |
| 429    | `TooManyRequests`     | `too_many_requests`     |
| 500    | `InternalServerError` | `internal_server_error` |
| 502    | `BadGateway`          | `bad_gateway`           |
| 503    | `ServiceUnavailable`  | `service_unavailable`   |

**[Complete list of all 39 HTTP status codes →](HTTP_STATUS_CODES.md)**

## Testing

### RSpec Integration

```ruby
# Shared examples for JSON:API compliance
RSpec.shared_examples 'JSON:API error response' do |expected_status, expected_code|
  it 'returns proper JSON:API error format' do
    json = JSON.parse(response.body)

    expect(response).to have_http_status(expected_status)
    expect(json['errors'].first['status']).to eq(expected_status)
    expect(json['errors'].first['code']).to eq(expected_code)
  end
end

# Usage in specs
describe 'GET #show' do
  context 'when user not found' do
    subject { get :show, params: { id: 'nonexistent' } }
    include_examples 'JSON:API error response', 404, 'not_found'
  end
end
```

### Unit Testing

```ruby
RSpec.describe HatiJsonapiError::NotFound do
  it 'has correct default attributes' do
    error = described_class.new

    expect(error.status).to eq(404)
    expect(error.code).to eq(:not_found)
    expect(error.to_h[:title]).to eq('Not Found')
  end
end
```

## Benefits

**For Development Teams:**

- Reduced development time with single error pattern
- Easier onboarding for new developers
- Better testing with standardized structure
- Improved debugging with consistent error tracking

**For Frontend/Mobile Teams:**

- One error parser for entire API
- Rich error context for better user experience
- Easier SDK development

**For Operations:**

- Centralized monitoring and alerting
- Consistent error analysis
- Simplified documentation

## Contributing

```bash
git clone https://github.com/hackico-ai/ruby-hati-jsonapi-error.git
cd ruby-hati-jsonapi-error
bundle install
bundle exec rspec
```

## License

MIT License - see [LICENSE](LICENSE) file.

---

**Professional error handling for professional APIs**
