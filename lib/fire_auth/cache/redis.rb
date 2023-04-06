module FireAuth
  module Cache
    class Redis
      def initialize(
        client:,
        cache_key: 'fire_auth/certificates'
      )
        @client = client
        @cache_key = key
      end

      def fetch
        current_time = Time.now.utc.to_i

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
          response[:data]
        )

        response[:data]
      end
    end
  end
end
