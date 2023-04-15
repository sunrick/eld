# frozen_string_literal: true

module Eld
  module Cache
    class Redis
      def initialize(
        client:,
        cache_key: "eld/certificates"
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

        # We calculate ex in seconds instead of using exat for
        # specs. Not ideal but good enough.
        # Probably should mock redis calls in tests.
        @client.set(
          @cache_key,
          response[:data].to_json,
          ex: response[:expires_at] - Time.now.utc.to_i
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
