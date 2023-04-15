# frozen_string_literal: true

module Eld
  module Cache
    class Memory
      def initialize
        @storage = {}
      end

      def fetch(&block)
        current_time = Time.now.utc.to_i

        if @storage[:data] && @storage[:expires_at] > current_time
          @storage[:data]
        else
          set(&block)
        end
      end

      def set(&block)
        response = block.call

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
