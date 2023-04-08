# frozen_string_literal: true

require_relative "fire_auth/version"
require_relative "fire_auth/cache"
require_relative "fire_auth/certificate"
require_relative "fire_auth/authenticator"

module FireAuth
  class Error < StandardError
  end

  class << self
    def configure
      yield(self)
    end

    def firebase_id
      @firebase_id
    end

    def firebase_id=(value)
      @firebase_id = value
    end

    def authenticator
      @authenticator ||= FireAuth::Authenticator.new(
        firebase_id: firebase_id
      )
    end

    def authenticator=(value)
      @authenticator = value
    end

    def cache
      @cache ||= FireAuth::Cache::Memory.new
    end

    def cache=(value)
      @cache = value
    end

    def authenticate(token)
      authenticator.authenticate(token)
    end
  end
end
