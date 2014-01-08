require 'rubygems'
require 'bundler/setup'
require 'vcr'

require 'bitbot'
require_relative '../lib/bitbot-bitfinex'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock

  c.filter_sensitive_data('<KEY>') do |interaction|
    headers = interaction.request.headers
    headers['X-Bfx-Apikey'].first if headers['X-Bfx-Apikey']
  end
  c.filter_sensitive_data('<Signature>') do |interaction|
    headers = interaction.request.headers
    headers['X-Bfx-Signature'].first if headers['X-Bfx-Signature']
  end
end

class Settings
  class << self
    def rate; 6.06 end
  end
end
