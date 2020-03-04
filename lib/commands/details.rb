# typed: ignore
# frozen_string_literal: true

require_relative './google_maps_api'

module Commands
  class Details < GoogleMapsAPI
    extend T::Sig

    sig { override.returns(String) }
    def self.name
      'details'
    end

    sig { override.returns(String) }
    def self.help
      <<~HELP
        details <place>: returns available info about a specific place listed on Google Maps.
        If there are more than one match, the command returns a list of the top 10 results instead.

        Examples:
        details living computers museum, seattle wa
        details korean restaurant victoria bc
      HELP
    end

    sig { override.returns(String) }
    def response_body
      return api_key_missing unless api_key_exists?

      return help if arg_text.empty?

      begin
        places = Google::Maps.places(arg_text)
        place = Google::Maps.place(places.first.place_id)
      rescue Google::Maps::ZeroResultsException
        return "NO RESULTS FOR \"#{arg_text}\""
      rescue => error
        return error.message
      end

      return "#{places.slice(0, 10).map.with_index { |e, i| "(#{i + 1}) #{e}" }.join(%Q{\n})}" if places.length > 1

      place_name = place.name
      place_address = place.address
      data = place.data
      data_phone = data.formatted_phone_number ? "\nPhone: #{data.formatted_phone_number}" : ''
      data_rating = data.rating ? "\nRating: #{data.rating}" : ''
      data_price_level = data.price_level ? "\nPrice level (0\{free\}-4): #{data.price_level}" : ''
      data_permanently_closed = data.permanently_closed ? 'PERMAMENTLY CLOSED' : ''
      data_hours = data.opening_hours
      open_now = defined?(data_hours.open_now) ? (data_hours.open_now ? "\nOpen now" : "\nClosed now") : ''
      weekday_hours = defined?(data_hours.weekday_text) ?
        "\nHours:\n* #{data.opening_hours.weekday_text.join(%Q{\n* })}"
        :
        ''
      response = "#{place_name}\n#{place_address}#{data_phone}#{data_rating}"\
        "#{data_price_level}#{data_permanently_closed}#{open_now}#{weekday_hours}"

      response
    end
  end
end
