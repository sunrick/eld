module FireAuth
  module Cache
    class Redis
      def initialize(
        client:,
        cache_key: "fire_auth/certificates"
      )
        @client = client
        @cache_key = cache_key
      end

      def fetch
        data = @client.get(@cache_key)

        if data
          JSON.parse(data)
        else
          set { yield }
        end
      end

      def set
        response = yield

        @client.setex(
          @cache_key,
          response[:expires_at],
          response[:data].to_json
        )

        response[:data]
      end

      def clear
        @client.del(@cache_key)

        nil
      end
    end
  end
end
