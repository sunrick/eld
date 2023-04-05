module FireAuth
  class Certificate
    GOOGLE_CERTIFICATES_URL =
    "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

    def self.certificates
      FireAuth.cache.fetch do
        response = HTTParty.get(GOOGLE_CERTIFICATES_URL)
        JSON.parse(response.body)
      end
    end

    def self.find(token)
      kid = JWT.decode(token, nil, false).last["kid"]

      certificate = certificates[kid]

      OpenSSL::X509::Certificate.new(certificate)
    end
  end
end
