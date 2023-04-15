# frozen_string_literal: true

require_relative "eld/version"
require_relative "eld/cache"
require_relative "eld/certificate"
require_relative "eld/authenticator"

module Eld
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
      @authenticator ||= Eld::Authenticator.new(
        firebase_id: firebase_id
      )
    end

    def authenticator=(value)
      @authenticator = value.new(firebase_id: firebase_id)
    end

    def cache
      @cache ||= Eld::Cache::Memory.new
    end

    def cache=(value)
      @cache = value
    end

    def authenticate(token)
      authenticator.authenticate(token)
    end
  end
end
