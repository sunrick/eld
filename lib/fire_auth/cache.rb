module FireAuth
  # Basic in memory storage
  # You'll be better off using Rails::Cache
  # or building your own caching mechanism.
  class Cache
    def self.storage
      @@storage ||= {}
    end

    def self.fetch(cache_key, expires_in:)
      data = storage[cache_key]
      current_time = Time.now.utc

      if data && data[:value] && data[:expires_at] > current_time
        if data[:expires_in] == expires_in
          data[:value]
        else
          set(cache_key, expires_in, current_time) { yield }
        end
      else
        set(cache_key, expires_in, current_time) { yield }
      end
    end

    def self.set(cache_key, expires_in, current_time)
      value = yield

      storage[cache_key] = {
        value: value,
        expires_in: expires_in,
        expires_at: current_time + expires_in
      }

      value
    end
  end
end
