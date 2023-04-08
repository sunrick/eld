# frozen_string_literal: true

module FireAuth
  module Cache
    class Memory
      def initialize
        @storage = {}
      end

      def fetch
        current_time = Time.now.utc.to_i

        if @storage[:data] && @storage[:expires_at] > current_time
          @storage[:data]
        else
          set { yield }
        end
      end

      def set
        response = yield

        @storage = response

        response[:data]
      end

      def clear
        @storage = {}

        nil
      end
    end
  end
end
