module FireAuth
  # Basic in memory storage
  # You'll be better off using Rails::Cache
  # or building your own caching mechanism.
  class Cache
    def self.data
      @@data ||= {}
    end

    def self.fetch
      expires_in = 3600
      current_time = Time.now.utc

      if data && data[:value] && data[:expires_at] > current_time
        if data[:expires_in] == expires_in
          data[:value]
        else
          set(current_time) { yield }
        end
      else
        set(current_time) { yield }
      end
    end

    def self.set(current_time)
      expires_in = 3600
      value = yield

      storage = {
        value: value,
        expires_in: expires_in,
        expires_at: current_time + expires_in
      }

      value
    end
  end
end
