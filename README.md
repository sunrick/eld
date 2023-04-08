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

```rb
FireAuth.configure do |c|
  c.firebase_id = "YOUR_FIREBASE_PROJECT_ID"
end


payload = FireAuth.authenticate("FIREBASE_ACCESS_TOKEN")

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
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sunrick/fire_auth. Please check the [code of conduct](https://github.com/sunrick/fire_auth/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
