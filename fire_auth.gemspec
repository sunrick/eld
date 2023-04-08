# frozen_string_literal: true

require_relative "lib/fire_auth/version"

Gem::Specification.new do |spec|
  spec.name = "fire_auth"
  spec.version = FireAuth::VERSION
  spec.authors = ["Rickard Sundén"]
  spec.email = ["rickardsunden@gmail.com"]

  spec.summary = "Firebase Authentication for Ruby applications."
  spec.homepage = "https://github.com/sunrick/fire_auth"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sunrick/fire_auth"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0")
        .reject do |f|
          (f == __FILE__) ||
            f.match(
              %r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)}
            )
        end
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jwt", "~> 2.7"
  spec.add_dependency "httparty", "~> 0.21"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.49"
  spec.add_development_dependency "vcr", "~> 6.1"
  spec.add_development_dependency "webmock", "~> 3.18"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "redis"
  spec.add_development_dependency 'simplecov'
end
