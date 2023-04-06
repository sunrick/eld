# frozen_string_literal: true

require "fire_auth"
require "vcr"
require "pry"
require "timecop"

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around(:each) do |example|
    if example.metadata[:cache] == :redis
      FireAuth.cache = FireAuth::Cache::Redis.new(
        client: Redis.new
      )
    else
      FireAuth.cache = FireAuth::Cache::Memory.new
    end

    FireAuth.cache.clear

    example.run
  end
end
