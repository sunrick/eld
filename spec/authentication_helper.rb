RSpec.shared_context 'Authentication' do
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
end
