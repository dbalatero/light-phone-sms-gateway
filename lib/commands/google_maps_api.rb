# typed: ignore
# frozen_string_literal: true

require_relative './base'
require 'google-maps'

Google::Maps.configure do |config|
  config.authentication_mode = Google::Maps::Configuration::API_KEY
  config.api_key = ENV['GOOGLE_MAPS_API_KEY']
end

module Commands
  class GoogleMapsAPI < Base
    private

    def api_key_missing
      <<~MSG
        Your Google Maps API key is missing.
        Create a new key at: https://developers.google.com/maps/gmp-get-started

        Once you get a key, set it to ENV['GOOGLE_MAPS_API_KEY'] on your server.
      MSG
    end

    def api_key_exists?
      ENV.key?('GOOGLE_MAPS_API_KEY')
    end
  end
end