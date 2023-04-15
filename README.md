# Eld

[![Gem Version](https://badge.fury.io/rb/eld.svg)](https://rubygems.org/gems/eld)
![Build](https://github.com/sunrick/eld/workflows/CI/badge.svg)
<a href="https://codeclimate.com/github/sunrick/eld/maintainability"><img src="https://api.codeclimate.com/v1/badges/5e8eadb4762ad371641c/maintainability" /></a>
<a href="https://codeclimate.com/github/sunrick/eld/test_coverage"><img src="https://api.codeclimate.com/v1/badges/5e8eadb4762ad371641c/test_coverage" /></a>
[![Known Vulnerabilities](https://snyk.io/test/github/sunrick/eld/badge.svg)](https://snyk.io/test/github/{username}/{repo})

[Firebase Authentication](https://firebase.google.com/docs/auth) for Ruby applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "eld"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install eld

## Usage

Eld takes a Firebase access token and decodes it. Once you've decoded the token, the rest is up to you!

See [Firebase Authentication](https://firebase.google.com/docs/auth) for example client implementations.

### Basic Usage
```rb
Eld.configure do |c|
  c.firebase_id = "FIREBASE_PROJECT_ID"
end

decoded_token = Eld.authenticate("FIREBASE_ACCESS_TOKEN")
# =>
{
  "iss" => "https://securetoken.google.com/fire-auth-67d5f",
  "aud" => "fire-auth-67d5f",
  "auth_time" => 1679606435,
  "user_id" => "Z02vuFq6RAU1NqVrWrdLAjyiqJ83",
  "sub" => "Z02vuFq6RAU1NqVrWrdLAjyiqJ83",
  "iat" => 1679606435,
  "exp" => 1679610035,
  "email" => "test@test.com",
  "email_verified" => false,
  "firebase" => {
    "identities" => {
      "email" => ["test@test.com"]
    },
    "sign_in_provider"=>"password"
  }
}

user = User.new(decoded_token)
```

### Advanced Setup

```rb
Eld.configure do |c|
  # Use one or more Firebase projects
  c.firebase_id = "FIREBASE_PROJECT_ID"
  # c.firebase_id = ["FIREBASE_PROJECT_ID_1", "FIREBASE_PROJECT_ID_2"]

  # Use Redis to cache (recommended)
  # By default we use Eld::Cache::Memory
  # You can also create your own cache implementation.
  c.cache = Eld::Cache::Redis.new(
    client: Redis.new, # Your redis client
    cache_key "eld/certificates" # Optional: This is the default key
  )

  # Use your own authenticator
  # See Eld::Authenticator for an example implementation.
  c.authenticator = CustomAuthenticator
end
```

### Certificates

The default behavior of Eld is to lazily handle caching and fetching certificates from Google when authenticating tokens. This means you don't have to worry about refreshing certificates at any particular interval. However, you can refresh the cache and fetch new certificates whenever you want should you need to.

```rb
Eld::Certificate.refresh
```

### Custom Authenticators

You can create your own authenticator and use it as a new default or build it anywhere.

Custom authenticators will still use Eld defaults for caching.

```rb
class CustomAuthenticator < Eld::Authenticator
  # The default behavior is to return the decoded token
  # You could add additional behavior like finding or instantiating
  # a user.
  def respond(decoded_token)
    User.find_by(uid: decoded_token['user_id'])
  end

  # The default authenticator swallows JWT errors
  # You might want to handle them on your own.
  def handle_error(error)
    ReportError.call(error)
    false
  end
end

# Set a new default authenticator
Eld.authenticator = CustomAuthenticator
Eld.authenticate(token)
# => User(uid: "1231231")

# Instantiate your own authenticator
authenticator = CustomAuthenticator.new(firebase_id: "FIREBASE_PROJECT_ID")
authenticator.authenticate(token)
# => User(uid: "1231231")
```

### Rails Example

```rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  helper_method :current_user

  def authenticate_user!
    @current_user = nil

    token = request.headers["X-Access-Token"]
    decoded_token = Eld.authenticate(token)

    if payload
      # Find a User from DB?
      # Find or create a User?
      @current_user = User.find_by(uid: decoded_token['user_id'])

      # Wrap data in a User object?
      @current_user = User.new(decoded_token)
    end

    head :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sunrick/eld. Please check the [code of conduct](https://github.com/sunrick/eld/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
