RSpec.describe FireAuth::Authenticator do
  let(:token) do
    "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOTczZWUwZTE2ZjdlZWY0ZjkyMWQ1MGRjNjFkNzBiMmVmZWZjMTkiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vZmlyZS1hdXRoLTY3ZDVmIiwiYXVkIjoiZmlyZS1hdXRoLTY3ZDVmIiwiYXV0aF90aW1lIjoxNjc5NjA2NDM1LCJ1c2VyX2lkIjoiWjAydnVGcTZSQVUxTnFWcldyZExBanlpcUo4MyIsInN1YiI6IlowMnZ1RnE2UkFVMU5xVnJXcmRMQWp5aXFKODMiLCJpYXQiOjE2Nzk2MDY0MzUsImV4cCI6MTY3OTYxMDAzNSwiZW1haWwiOiJ0ZXN0QHRlc3QuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbInRlc3RAdGVzdC5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwYXNzd29yZCJ9fQ.jz_KwazKwRp-kva9cwdFTxGZ-BL4OGFsnXEdI1vMKYzf8eh8lIhYOrcXhx7xuc2hrWPkfB4lZ-yBs82IdDCuk5yBqyhzbyWrR9kxxshkZoQGEM-_BgrPuXEk8WfmzhNTRJCmnL0Xq-vyBIAwFqpBrUBMa11QAtzLWhqSXJ9PJlnfT-933mxDxP43WjzyQoZNoVAJYH4WjsLmAfAAzu7_8G3wgXG-Hi6K1DnKBcDW2Y4C80mD7LNdCbxZ3Tnmtq_WvKK50BgSV99Tcbmxbn2oyQtLBQ2STCo3wcSeJBy9Mry1Q32BRPOLVn6wr9vUqxRnKwa1VQI2Rbu2JmJoNsZcLQ"
  end
  let(:firebase_id) { "fire-auth-67d5f" }

  let(:current_time) { Time.at(auth_time + 5).utc }
  let(:auth_time) { 1_679_606_435 }
  let(:iat) { 1_679_606_435 }
  let(:exp) { 1_679_610_035 }

  let(:decoded_token) do
    {
      "iss" => "https://securetoken.google.com/fire-auth-67d5f",
      "aud" => "fire-auth-67d5f",
      "auth_time" => auth_time,
      "user_id" => "Z02vuFq6RAU1NqVrWrdLAjyiqJ83",
      "sub" => "Z02vuFq6RAU1NqVrWrdLAjyiqJ83",
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

  context "#authenticate" do
    around do |example|
      VCR.use_cassette("google_certificates") do
        Timecop.freeze(current_time) { example.run }
      end
    end

    context "token can be decoded" do
      context "single firebase project" do
        it "returns decoded token" do
          authenticator = FireAuth.build(firebase_id: firebase_id)
          expect(authenticator.authenticate(token)).to eq(decoded_token)
        end
      end

      context "multiple firebase projects" do
        it "returns decoded token" do
          authenticator = FireAuth.build(firebase_id: ["test1", firebase_id])
          expect(authenticator.authenticate(token)).to eq(decoded_token)
        end
      end

      context "bad audience" do
        it "returns false" do
        end
      end

      context "auth_time is in future" do
        it "returns false" do
        end
      end

      context "nil subject" do
        it "returns false" do
        end
      end

      context "empty subject" do
        it "returns false" do
        end
      end

      context "subject does not match user_id" do
        it "returns false" do
        end
      end

      context "iat" do
        it "returns false" do
        end
      end

      context "token (exp) expired" do
        it "returns false" do
        end
      end
    end

    context "token cannot be decoded" do
      it "returns false" do
        authenticator = FireAuth.build(firebase_id: firebase_id)
        expect(authenticator.authenticate("test")).to eq(false)
      end
    end

    context "nil token" do
      it "returns false" do
        authenticator = FireAuth.build(firebase_id: firebase_id)
        expect(authenticator.authenticate(nil)).to eq(false)
      end
    end

    context "empty token" do
      it "returns false" do
        authenticator = FireAuth.build(firebase_id: firebase_id)
        expect(authenticator.authenticate("")).to eq(false)
      end
    end
  end
end
