# frozen_string_literal: true

require "redis"

RSpec.describe FireAuth::Authenticator do
  let(:token) do
    "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOTczZWUwZTE2ZjdlZWY0ZjkyMWQ1MGRjNjFkNzBiMmVmZWZjMTkiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZmlyZS1hdXRoLTY3ZDVmIiwiYXVkIjoiZmlyZS1hdXRoLTY3ZDVmIiwiYXV0aF90aW1lIjoxNjc5NjA2NDM1LCJ1c2VyX2lkIjoiWjAydnVGcTZSQVUxTnFWcldyZExBanlpcUo4MyIsInN1YiI6IlowMnZ1RnE2UkFVMU5xVnJXcmRMQWp5aXFKODMiLCJpYXQiOjE2Nzk2MDY0MzUsImV4cCI6MTY3OTYxMDAzNSwiZW1haWwiOiJ0ZXN0QHRlc3QuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbInRlc3RAdGVzdC5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwYXNzd29yZCJ9fQ.jz_KwazKwRp-kva9cwdFTxGZ-BL4OGFsnXEdI1vMKYzf8eh8lIhYOrcXhx7xuc2hrWPkfB4lZ-yBs82IdDCuk5yBqyhzbyWrR9kxxshkZoQGEM-_BgrPuXEk8WfmzhNTRJCmnL0Xq-vyBIAwFqpBrUBMa11QAtzLWhqSXJ9PJlnfT-933mxDxP43WjzyQoZNoVAJYH4WjsLmAfAAzu7_8G3wgXG-Hi6K1DnKBcDW2Y4C80mD7LNdCbxZ3Tnmtq_WvKK50BgSV99Tcbmxbn2oyQtLBQ2STCo3wcSeJBy9Mry1Q32BRPOLVn6wr9vUqxRnKwa1VQI2Rbu2JmJoNsZcLQ"
  end

  let(:firebase_id) { "fire-auth-67d5f" }
  let(:iss) { "https://securetoken.google.com/#{firebase_id}" }
  let(:aud) { firebase_id }
  let(:user_id) { "Z02vuFq6RAU1NqVrWrdLAjyiqJ83" }
  let(:sub) { user_id }
  let(:current_time) { 1_679_606_440 }
  let(:auth_time) { 1_679_606_435 }
  let(:iat) { 1_679_606_435 }
  let(:exp) { 1_679_610_035 }

  let(:decoded_token) do
    {
      "iss" => iss,
      "aud" => aud,
      "auth_time" => auth_time,
      "user_id" => user_id,
      "sub" => sub,
      "iat" => iat,
      "exp" => exp,
      "email" => "test@test.com",
      "email_verified" => false,
      "firebase" => {
        "identities" => {
          "email" => ["test@test.com"]
        },
        "sign_in_provider" => "password"
      }
    }
  end

  before do
    FireAuth.configure do |c|
      c.firebase_id = firebase_id
    end
  end

  describe "#authenticate" do
    around do |example|
      VCR.use_cassette("google_certificates") do
        Timecop.freeze(Time.at(current_time).utc) { example.run }
      end
    end

    context "token can be decoded" do
      context "single firebase project" do
        context "memory cache" do
          it "returns decoded token" do
            expect(FireAuth.authenticate(token)).to eq(decoded_token)
          end

          it "works when certficiate is cached" do
            expect(HTTParty).to receive(
              :get
            ).with(
              "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
            ).once.and_call_original

            expect(FireAuth.authenticate(token)).to eq(decoded_token)
            expect(FireAuth.authenticate(token)).to eq(decoded_token)
          end
        end

        context "redis cache", cache: :redis do
          it "returns decoded token" do
            expect(FireAuth.authenticate(token)).to eq(decoded_token)
          end

          it "works when certificates are cached" do
            expect(HTTParty).to receive(
              :get
            ).with(
              "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
            ).once.and_call_original

            expect(FireAuth.authenticate(token)).to eq(decoded_token)
            expect(FireAuth.authenticate(token)).to eq(decoded_token)
          end
        end
      end

      context "multiple firebase projects" do
        let(:authenticator) { described_class.new(firebase_id: ["test1", firebase_id]) }

        context "memory cache" do
          it "returns decoded token" do
            expect(FireAuth.authenticate(token)).to eq(decoded_token)
          end
        end

        context "redis cache", cache: :redis do
          around do |example|
            FireAuth.cache = FireAuth::Cache::Redis.new(
              client: Redis.new
            )

            example.run

            FireAuth.cache = FireAuth::Cache::Memory.new
          end

          it "returns decoded token" do
            expect(FireAuth.authenticate(token)).to eq(decoded_token)
          end
        end
      end

      context "bad audience" do
        let(:aud) { "bad" }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "auth_time is current time" do
        let(:auth_time) { current_time }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "auth_time is in future" do
        let(:auth_time) { current_time + 5 }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "nil subject" do
        let(:sub) { nil }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "empty subject" do
        let(:sub) { "" }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "subject does not match user_id" do
        let(:sub) { "bad" }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "iat is current time" do
        let(:iat) { current_time }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "iat is in the future" do
        let(:iat) { current_time + 5 }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "exp is current time" do
        let(:exp) { current_time }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "exp is in the past" do
        let(:exp) { current_time - 5 }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
          expect(FireAuth.authenticate(token)).to eq(false)
        end
      end

      context "iss does not match" do
        let(:iss) { "https://securetoken.google.com/bad" }

        it "returns false" do
          expect(FireAuth.authenticator).to receive(:decode_token).and_return(
            decoded_token
          )
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
