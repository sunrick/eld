# frozen_string_literal: true

module Eld
  class Certificate
    GOOGLE_CERTIFICATES_URL =
      "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

    def self.all
      Eld.cache.fetch do
        response = HTTParty.get(GOOGLE_CERTIFICATES_URL)

        {
          expires_at: Time.parse(response.headers["expires"]).utc.to_i,
          data: JSON.parse(response.body)
        }
      end
    end

    def self.find(kid)
      certificate = all[kid]

      OpenSSL::X509::Certificate.new(certificate)
    end

    def self.refresh
      Eld.cache.clear
      all
    end
  end
end
