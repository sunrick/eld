# frozen_string_literal: true

require "jwt"
require "httparty"

module Eld
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

      certificate = Eld::Certificate.find(kid)

      decoded_token = decode_token(token, certificate.public_key)

      valid_token?(decoded_token) && respond(decoded_token)
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

    def valid_token?(decoded_token)
      current_time = Time.now.utc.to_i

      !decoded_token.empty? &&
      decoded_token["exp"].to_i > current_time &&
      decoded_token["iat"].to_i < current_time &&
      decoded_token["auth_time"].to_i < current_time &&
      valid_sub?(decoded_token) &&
      valid_firebase_id?(decoded_token)
    end

    def valid_sub?(decoded_token)
      !decoded_token["sub"].nil? &&
      !decoded_token["sub"].empty? &&
      decoded_token["sub"] == decoded_token["user_id"]
    end

    def valid_firebase_id?(decoded_token)
      @firebase_id.any? do |id|
        decoded_token["aud"] == id && decoded_token["iss"] == "#{GOOGLE_ISS}/#{id}"
      end
    end

    def respond(decoded_token)
      decoded_token
    end

    def handle_error(_error)
      false
    end
  end
end
