module FireAuth
  class Token
    GOOGLE_CERTIFICATES_URL ='https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
    GOOGLE_ISS = 'https://securetoken.google.com'

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
    def initialize(
      firebase_project_ids:,
      cache: nil,
      cache_key: 'fire_auth/certificates',
      cache_expires_in: 3600 # 1 hour
    )
      @firebase_project_ids = Array(firebase_project_id)

      if defined?(Rails)
        @cache = Rails::Cache
      else
        @cache = Fire::Cache
      end

      @cache_key = cache_key
      @cache_expires_in = cache_expires_in
    end

    def verify(token)
      token = token.to_s

      return false if token.empty?

      certificate = find_certificate(token)

      payload = JWT.decode(
        token,
        certificate.public_key,
        true,
        algorithm: 'RS256',
        verify_iat: true
      ).first

      valid_token?(payload) ? payload : false
    end

    def certificates
      @cache.fetch(@cache_key, expires_in: @cache_expires_in) do
        http_certificates
      end
    end

    def http_certificates
      response = HTTParty.get(GOOGLE_CERTIFICATES_URL)
      JSON.parse(response.body)
    end

    def find_certificate(token)
      kid = JWT.decode(token, nil, false).last['kid']
      certificate = certificates[kid]
      OpenSSL::X509::Certificate.new(certificate)
    end

    def valid_token?(payload)
      current_time = Time.now.utc.to_i

      !payload.empty? &&
      payload['exp'].to_i > current_time &&
      payload['iat'].to_i < current_time &&
      payload['auth_time'] < current_time &&
      valid_firebase_id?(payload) &&
      payload['sub'].present?
    end

    def valid_firebase_id?(payload)
      @firebase_project_ids.any? do |id|
        payload['aud'] == id &&
        payload['iss'] == "#{GOOGLE_ISS}/#{id}"
      end
    end
  end
end
