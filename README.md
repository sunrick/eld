# FireAuth

[![Gem Version](https://badge.fury.io/rb/fire_auth.svg)](https://rubygems.org/gems/fire_auth)
![Build](https://github.com/sunrick/fire_auth/workflows/CI/badge.svg)
<a href="https://codeclimate.com/github/sunrick/fire_auth/maintainability"><img src="https://api.codeclimate.com/v1/badges/5e8eadb4762ad371641c/maintainability" /></a>
<a href="https://codeclimate.com/github/sunrick/fire_auth/test_coverage"><img src="https://api.codeclimate.com/v1/badges/5e8eadb4762ad371641c/test_coverage" /></a>
[![Known Vulnerabilities](https://snyk.io/test/github/sunrick/fire_auth/badge.svg)](https://snyk.io/test/github/{username}/{repo})

[Firebase Authentication](https://firebase.google.com/docs/auth) for Ruby applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "fire_auth"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fire_auth

## Usage

By default FireAuth is designed to be simple as possible. It's up to you how you want to build on top of FireAuth.

FireAuth allows you to take a Firebase access token from your frontend of choice and decode it. Once you've decoded the token, the rest is up to you!

See [Firebase Authentication](https://firebase.google.com/docs/auth) for example client implementations.


### Basic Usage

FireAuth is designed to work with any Ruby application. As long as you have a way of getting a Firebase access token to your app, you are good to go. Use it with Sinatra, Roda, or Rails. Up to you!

```rb
FireAuth.configure do |c|
  c.firebase_id = "YOUR_FIREBASE_PROJECT_ID"
end

decoded_token = FireAuth.authenticate("FIREBASE_ACCESS_TOKEN")
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
FireAuth.configure do |c|
  # Use one or more Firebase projects
  c.firebase_id = "YOUR_FIREBASE_PROJECT_ID"
  # c.firebase_id = ["YOUR_FIREBASE_PROJECT_ID_1", "YOUR_FIREBASE_PROJECT_ID_2"]

  # Use Redis to cache (recommended)
  # By default we use FireAuth::Cache::Memory
  # You can also create your own cache implementation.
  c.cache = FireAuth::Cache::Redis.new(
    client: Redis.new, # Your redis client
    cache_key "fire_auth/certificates" # Optional: This is the default key
  )

  # Use your own authenticator
  # See FireAuth::Authenticator for an example implementation.
  c.authenticator = CustomAuthenticator
end
```

### Rails Example

```rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  helper_method :current_user

  def authenticate_user!
    @current_user = nil

    token = request.headers["X-Authentication"]
    decoded_token = FireAuth.authenticate(token)

    if payload
      # Find a User from DB?
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

Bug reports and pull requests are welcome on GitHub at https://github.com/sunrick/fire_auth. Please check the [code of conduct](https://github.com/sunrick/fire_auth/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
