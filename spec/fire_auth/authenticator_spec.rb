# frozen_string_literal: true

require "redis"
require_relative "../authentication_helper"

RSpec.describe FireAuth::Authenticator do
  include_context 'Authentication'

  shared_examples "caches correctly" do
    it "returns decoded token" do
      expect(HTTParty).to receive(
        :get
      ).with(
        "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
      ).once.and_call_original

      expect(FireAuth.authenticate(token)).to eq(decoded_token)
    end

    it "works when certificate is cached" do
      expect(HTTParty).to receive(
        :get
      ).with(
        "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
      ).once.and_call_original

      expect(FireAuth.authenticate(token)).to eq(decoded_token)
      expect(FireAuth.authenticate(token)).to eq(decoded_token)
    end
  end

  describe "#authenticate" do
    context "single firebase project" do
      context "memory cache" do
        include_examples "caches correctly"
      end

      context "redis cache", cache: :redis do
        include_examples "caches correctly"
      end
    end

    context "multiple firebase projects" do
      let(:authenticator) { described_class.new(firebase_id: ["test1", firebase_id]) }

      it "returns decoded token" do
        expect(FireAuth.authenticate(token)).to eq(decoded_token)
      end

      context "with redis cache", cache: :redis do
        it "returns decoded token with redis cache" do
          expect(FireAuth.authenticate(token)).to eq(decoded_token)
        end
      end
    end

    context "bad payload" do
      before do
        allow(FireAuth.authenticator).to receive(:decode_token).and_return(
          decoded_token
        )
      end

      context "bad audience" do
        let(:aud) { "bad" }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "auth_time is current time" do
        let(:auth_time) { current_time }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "auth_time is in future" do
        let(:auth_time) { current_time + 5 }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "nil subject" do
        let(:sub) { nil }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "empty subject" do
        let(:sub) { "" }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "subject does not match user_id" do
        let(:sub) { "bad" }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "iat is current time" do
        let(:iat) { current_time }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "iat is in the future" do
        let(:iat) { current_time + 5 }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "exp is current time" do
        let(:exp) { current_time }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "exp is in the past" do
        let(:exp) { current_time - 5 }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "iss does not match" do
        let(:iss) { "https://securetoken.google.com/bad" }

        it "returns false" do
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end
    end

    context "token is not formatted correctly" do
      it "returns false" do
        expect(FireAuth.authenticate("test")).to eq(false)
      end
    end

    context "nil token" do
      it "returns false" do
        expect(FireAuth.authenticate(nil)).to eq(false)
      end
    end

    context "empty token" do
      it "returns false" do
        expect(FireAuth.authenticate("")).to eq(false)
      end
    end
  end
end
