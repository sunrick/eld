# frozen_string_literal: true

RSpec.shared_context "Setup" do
  let(:redis) { Redis.new }
  let(:firebase_id) { "fire-auth-67d5f" }
  let(:current_time) { 1_679_606_440 }

  before do
    FireAuth.configure do |c|
      c.firebase_id = firebase_id
    end
  end

  around do |example|
    VCR.use_cassette("google_certificates", allow_playback_repeats: true) do
      Timecop.freeze(Time.at(current_time).utc) do
        FireAuth.cache = if example.metadata[:cache] == :redis
                           FireAuth::Cache::Redis.new(
                             client: redis
                           )
                         else
                           FireAuth::Cache::Memory.new
                         end

        FireAuth.cache.clear

        example.run
      end
    end
  end
end
