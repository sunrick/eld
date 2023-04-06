# FireAuth

A Ruby gem that helps you authenticate users with Firebase Authentication.

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

TODO: Write usage instructions here

```rb
FireAuth.configure do |c|
  c.firebase_id = 'YOUR_FIREBASE_PROJECT_ID'
end


payload = FireAuth.authenticate('FIREBASE_ACCESS_TOKEN')
# => {
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
