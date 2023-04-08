# frozen_string_literal: true

require "jwt"
require "httparty"

module FireAuth
  class Authenticator
    GOOGLE_ISS = "https://securetoken.google.com"

    # See Firebase docs for implemenation details
    # https://firebase.google.com/docs/auth/admin/verify-id-tokens?authuser=0#verify_id_tokens_using_a_third-party_jwt_library

    #############
    # Glossary: #
    #############
    # exp	Expiration time	Must be in the future. The time is measured in seconds since the UNIX epoch.
    # iat	Issued-at time	Must be in the past. The time is measured in seconds since the UNIX epoch.
    # aud	Audience	Must be your Firebase project ID, the unique identifier for your Firebase project, which can be found in the URL of that project's console.
    # iss	Issuer	Must be "https://securetoken.google.com/<projectId>", where <projectId> is the same project ID used for aud above.
    # sub	Subject	Must be a non-empty string and must be the uid of the user or device.
    # auth_time	Authentication time	Must be in the past. The time when the user authenticated.

    def initialize(firebase_id:)
      @firebase_id = Array(firebase_id)
    end

    def authenticate(token)
      return false if token.nil? || token.empty?

      kid = JWT.decode(token, nil, false).last["kid"]

      certificate = FireAuth::Certificate.find(kid)

      payload = decode_token(token, certificate.public_key)

      valid_token?(payload) && payload
    rescue JWT::DecodeError => e
      handle_error(e)
    end

    def decode_token(token, public_key)
      JWT.decode(
        token,
        public_key,
        true,
        algorithm: "RS256",
        verify_expiration: false # we verify this manually
      ).first
    end

    def valid_token?(payload)
      current_time = Time.now.utc.to_i

      !payload.empty? &&
      payload["exp"].to_i > current_time &&
      payload["iat"].to_i < current_time &&
      payload["auth_time"].to_i < current_time &&
      valid_sub?(payload) &&
      valid_firebase_id?(payload)
    end

    def valid_sub?(payload)
      !payload["sub"].nil? &&
      !payload["sub"].empty? &&
      payload["sub"] == payload["user_id"]
    end

    def valid_firebase_id?(payload)
      @firebase_id.any? do |id|
        payload["aud"] == id && payload["iss"] == "#{GOOGLE_ISS}/#{id}"
      end
    end

    def handle_error(_error)
      false
    end
  end
end
