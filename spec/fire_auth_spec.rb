# frozen_string_literal: true

RSpec.describe FireAuth do
  it "has a version number" do
    expect(FireAuth::VERSION).not_to be nil
  end

  context '.build' do
    it 'cannot be built without a project id' do
      expect {
        authenticator = FireAuth.build
      }.to raise_error(ArgumentError)
    end

    it 'can be built with one project id' do
      authenticator = FireAuth.build(firebase_ids: 'test1')

      expect(authenticator.firebase_ids).to eq(['test1'])

      expect(authenticator.cache).to eq(FireAuth::Cache)
      expect(authenticator.cache_key).to eq('fire_auth/certificates')
      expect(authenticator.cache_expires_in).to eq(3600)
    end

    it 'can be built with multiple project ids' do
      authenticator = FireAuth.build(firebase_ids: ['test1', 'test2'])
      expect(authenticator.firebase_ids).to eq(['test1', 'test2'])
    end

    it 'can be built with everything' do
      FakeCache = Class.new


      authenticator = FireAuth.build(
        firebase_ids: 'test1',
        cache: FakeCache,
        cache_key: 'test_key',
        cache_expires_in: 30
      )

      expect(authenticator.firebase_ids).to eq(['test1'])

      expect(authenticator.cache).to eq(FakeCache)
      expect(authenticator.cache_key).to eq('test_key')
      expect(authenticator.cache_expires_in).to eq(30)
    end

    it 'can be built with rails cache' do
      class Rails
        def self.cache
          'rails_cache'
        end
      end

      authenticator = FireAuth.build(firebase_ids: 'test1')

      expect(authenticator.cache).to eq(Rails.cache)
    end
  end
end
