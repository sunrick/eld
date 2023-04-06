# frozen_string_literal: true

require_relative "fire_auth/version"
require_relative "fire_auth/cache"
require_relative "fire_auth/certificate"
require_relative "fire_auth/authenticator"

module FireAuth
  class Error < StandardError
  end

  def self.configure
    yield(FireAuth)
  end

  def self.firebase_id
    @@firebase_id
  end

  def self.firebase_id=(value)
    @@firebase_id = value
  end

  def self.authenticator
    @@authenticator ||= FireAuth::Authenticator.new(
      firebase_id: firebase_id
    )
  end

  def self.authenticator=(value)
    @@authenticator = value
  end

  def self.cache
    @@cache ||= FireAuth::Cache::Memory.new
  end

  def self.cache=(value)
    @@cache = value
  end

  def self.authenticate(token)
    authenticator.authenticate(token)
  end
end
