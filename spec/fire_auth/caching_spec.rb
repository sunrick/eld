require "redis"
require_relative "../authentication_helper"

RSpec.describe 'Caching' do
  include_context 'Authentication'

  context "with redis", cache: :redis do

  end

  context "with memory" do

  end
end
