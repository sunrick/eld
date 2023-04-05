module FireAuth
  class Certificate
    GOOGLE_CERTIFICATES_URL =
    "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

    def self.all
      FireAuth.cache.fetch do
        response = HTTParty.get(GOOGLE_CERTIFICATES_URL)
        JSON.parse(response.body)
      end
    end

    def self.find(kid)
      certificate = all[kid]

      OpenSSL::X509::Certificate.new(certificate)
    end
  end
end
