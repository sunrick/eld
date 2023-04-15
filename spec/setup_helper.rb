# frozen_string_literal: true

RSpec.shared_context "Setup" do
  let(:redis) { Redis.new }
  let(:firebase_id) { "fire-auth-67d5f" }
  let(:current_time) { 1_679_606_440 }

  before do
    Eld.configure do |c|
      c.firebase_id = firebase_id
    end
  end

  around do |example|
    VCR.use_cassette("google_certificates", allow_playback_repeats: true) do
      Timecop.freeze(Time.at(current_time).utc) do
        Eld.cache = if example.metadata[:cache] == :redis
                           Eld::Cache::Redis.new(
                             client: redis
                           )
                         else
                           Eld::Cache::Memory.new
                         end

        Eld.cache.clear

        example.run
      end
    end
  end
end
