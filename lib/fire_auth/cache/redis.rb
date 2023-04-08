# frozen_string_literal: true

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

      def fetch(&block)
        data = @client.get(@cache_key)

        if data
          JSON.parse(data)
        else
          set(&block)
        end
      end

      def set(&block)
        response = block.call

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
