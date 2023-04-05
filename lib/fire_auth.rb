# frozen_string_literal: true

require_relative "fire_auth/version"
require_relative "fire_auth/cache"
require_relative "fire_auth/authenticator"

module FireAuth
  class Error < StandardError
  end
  # Your code goes here...

  def self.build(**options)
    FireAuth::Authenticator.new(**options)
  end
end
