# frozen_string_literal: true

require_relative "fire_auth/version"
require_relative "fire_auth/cache"
require_relative "fire_auth/certificate"
require_relative "fire_auth/authenticator"

module FireAuth
  class Error < StandardError
  end

  def self.build(**options)
    FireAuth::Authenticator.new(**options)
  end

  def self.cache
    @@cache ||= FireAuth::Cache.new
  end

  def self.cache=(value)
    @@cache = value
  end
end
