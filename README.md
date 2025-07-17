# 🔥 Hati JSON:API Error

[![Gem Version](https://badge.fury.io/rb/hati-jsonapi-error.svg)](https://badge.fury.io/rb/hati-jsonapi-error)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.0.0-ruby.svg)](https://ruby-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Standardized JSON:API-compliant error responses made easy for your Web API** 🚀

Transform messy error handling into elegant, consistent JSON:API responses. Built for Ruby applications that demand professional error management.

## ✨ Features

- **JSON:API Compliant** - Follows the official [JSON:API error specification](https://jsonapi.org/format/#errors)
- **Auto-Generated Error Classes** - Dynamic HTTP status code error classes (400-511)
- **Customizable Attributes** - Support for `id`, `code`, `title`, `detail`, `status`, `meta`, `links`, `source`
- **Error Registry** - Map custom exceptions to standardized responses
- **Fallback Handling** - Graceful handling of unexpected errors
- **Zero Dependencies** - Lightweight and fast
- **Framework Agnostic** - Works with Rails, Sinatra, or any Ruby web framework

## 📦 Installation

Add this line to your application's Gemfile:

```ruby
gem 'hati-jsonapi-error'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install hati-jsonapi-error
```

## 🚀 Quick Start

### 1. Load Error Classes

```ruby
# config/hati_jsonapi_error.rb
require 'hati_jsonapi_error'

# Load all HTTP status error classes
HatiJsonapiError::Config.configure do |config|
  config.load_errors!
end
```

### 2. Basic Usage

```ruby
# Raise predefined errors
raise HatiJsonapiError::NotFound.new
raise HatiJsonapiError::BadRequest.new
raise HatiJsonapiError::InternalServerError.new

# Access by status code or symbol
JsonapiError = HatiJsonapiError::Helpers::ApiErr.new
raise JsonapiError[404]          # => HatiJsonapiError::NotFound
raise JsonapiError[:not_found]   # => HatiJsonapiError::NotFound
raise JsonapiError[422]          # => HatiJsonapiError::UnprocessableEntity

# NOTE: if namespacing is too verbosy - aliases are nice tricks (scoped preferably)
Error = HatiJsonapiError
raise Error::NotFound.new
```

### 3. Custom Error Attributes

```ruby
class CustomNotFound < HatiJsonapiError::NotFound
  def initialize
    super(
      id: 'user_not_found',
      detail: 'The requested user could not be found in our system',
      meta: { timestamp: Time.current, request_id: SecureRandom.uuid }
    )
  end
end

error = CustomNotFound.new
puts error.to_json
# {
#   "errors": [{
#     "id": "user_not_found",
#     "status": "404",
#     "code": "not_found",
#     "title": "Not Found",
#     "detail": "The requested user could not be found in our system",
#     "meta": {
#       "timestamp": "2024-01-15T10:30:00Z",
#       "request_id": "abc-123-def"
#     }
#   }]
# }
```

## 🔧 Configuration

### Error Mapping

Map your custom exceptions to standardized JSON:API errors:

```ruby
HatiJsonapiError::Config.configure do |config|
  config.load_errors!

  config.map_errors = {
    ActiveRecord::RecordNotFound  => :not_found,
    ActiveRecord::RecordInvalid   => 422,
    MyCustomError                 => HatiJsonapiError::BadRequest,
    AuthenticationError           => :unauthorized
  }

  # Set fallback for unmapped errors
  config.use_unexpected = HatiJsonapiError::InternalServerError
end
```

### Controller Integration

Include helpers in your API controllers:

```ruby
class ApiController < ApplicationController
  include HatiJsonapiError::Helpers

  rescue_from StandardError, with: :handle_error

  # ...
end

class UsersController < ApiController
  def show
    # Raises ActiveRecord::RecordNotFound and caught in rescue_from
    user = User.find(params[:id])

    render json: user, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    log_error(e)

   render_error HatiJsonapiError::UnprocessableEntity
  end
end
```

## 🎯 Advanced Usage

### Functional Programming Style

Perfect for functional programming patterns [SEE hati-operation gem](https://github.com/hackico-ai/ruby-hati-operation):

```ruby
require 'hati_operation'

class Api::User::CreateOperation < BaseOperation
  Err = HatiJsonapiError::Helpers::ApiErr.new

  def call(params)
    user_params = step validate_params(params), err: Err[422]
    user = step create_user(user_params),       err: Err[409]
    profile = step create_profile(user),        err: Err[503]

    Success(profile)
  end
end
```

### Complex Error Objects

Create rich error responses with all JSON:API features:

```ruby
class ValidationError < HatiJsonapiError::UnprocessableEntity
  def initialize(field:, value:, constraint:)
    super(
      id: "validation_#{field}",
      detail: "Field '#{field}' with value '#{value}' violates constraint: #{constraint}",
      source: {
        pointer: "/data/attributes/#{field}",
        parameter: field
      },
      meta: {
        field: field,
        value: value,
        constraint: constraint,
        help_url: "https://docs.example.com/validation##{field}"
      }
    )
  end
end

error = ValidationError.new(
  field: 'email',
  value: 'invalid-email',
  constraint: 'must be a valid email format'
)
```

### Batch Error Responses

Handle multiple errors in a single response:

```ruby
errors = [
  HatiJsonapiError::BadRequest.new(detail: "Missing required field: name"),
  HatiJsonapiError::BadRequest.new(detail: "Invalid email format")
]

resolver = HatiJsonapiError::Resolver.new(errors)
render json: resolver.to_json, status: resolver.status
```

## 📚 Available Error Classes

All standard HTTP error status codes are available:

### Client Errors (4xx)

- `BadRequest` (400)
- `Unauthorized` (401)
- `PaymentRequired` (402)
- `Forbidden` (403)
- `NotFound` (404)
- `MethodNotAllowed` (405)
- `NotAcceptable` (406)
- `ProxyAuthenticationRequired` (407)
- `RequestTimeout` (408)
- `Conflict` (409)
- `Gone` (410)
- `LengthRequired` (411)
- `PreconditionFailed` (412)
- `RequestEntityTooLarge` (413)
- `RequestUriTooLong` (414)
- `UnsupportedMediaType` (415)
- `RequestedRangeNotSatisfiable` (416)
- `ExpectationFailed` (417)
- `MisdirectedRequest` (421)
- `UnprocessableEntity` (422)
- `Locked` (423)
- `FailedDependency` (424)
- `TooEarly` (425)
- `UpgradeRequired` (426)
- `PreconditionRequired` (428)
- `TooManyRequests` (429)
- `RequestHeaderFieldsTooLarge` (431)
- `UnavailableForLegalReasons` (451)

### Server Errors (5xx)

- `InternalServerError` (500)
- `NotImplemented` (501)
- `BadGateway` (502)
- `ServiceUnavailable` (503)
- `GatewayTimeout` (504)
- `HttpVersionNotSupported` (505)
- `VariantAlsoNegotiates` (506)
- `InsufficientStorage` (507)
- `LoopDetected` (508)
- `BandwidthLimitExceeded` (509)
- `NotExtended` (510)
- `NetworkAuthenticationRequired` (511)

## 🧪 Testing

```ruby
# In your tests
RSpec.describe 'Error handling' do
  it 'returns proper JSON:API error format' do
    expect {
      raise HatiJsonapiError::NotFound.new(detail: 'User not found')
    }.to raise_error(HatiJsonapiError::NotFound) do |error|
      json = JSON.parse(error.to_json)
      expect(json['errors'].first['status']).to eq('404')
      expect(json['errors'].first['detail']).to eq('User not found')
    end
  end
end
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## 📝 License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🙏 Acknowledgments

- Inspired by the [JSON:API specification](https://jsonapi.org/)
- Built with ❤️ by the [hackico.ai](https://hackico.ai) team

---

**Made with ❤️ for the Ruby community**
