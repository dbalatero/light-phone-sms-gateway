# typed: false
# frozen_string_literal: true

require_relative './base'
require 'google-maps'

Google::Maps.configure do |config|
  config.authentication_mode = Google::Maps::Configuration::API_KEY
  config.api_key = ENV['GOOGLE_MAPS_API_KEY']
end

module Commands
  class Directions < Base
    extend T::Sig

    class Mode < T::Enum
      enums do
        Bicycling = new
        Driving = new
        Walking = new
        Transit = new
      end
    end

    sig { override.returns(String) }
    def self.name
      'directions'
    end

    def self.help
      <<~HELP
        directions [#{Query::MODES.join('|')}] <start> to <destination>
      HELP
    end

    sig { override.returns(String) }
    def response_body
      query = build_query
      return api_key_missing unless api_key_exists?
      return help unless query

      options = {}
      case query.mode
      when Mode::Transit
        options[:mode] = 'transit'
        options[:transit_routing_mode] = 'fewer_transfers'
        options[:transit_mode] = query.transit_mode if query.transit_mode
      when Mode::Walking
        options[:mode] = 'walking'
      when Mode::Bicycling
        options[:mode] = 'bicycling'
      when Mode::Driving
        options[:mode] = 'driving'
      end

      route = Google::Maps.route(
        query.start,
        query.destination,
        **options
      )

      RoutePresenter.new(route, mode: query.mode).to_text
    end

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

    class Query < T::Struct
      extend T::Sig

      const :start, String
      const :destination, String
      const :mode_type, String, default: 'transit'

      MODES = %w[rail bus transit walk bike drive].freeze

      sig { returns(T.nilable(String)) }
      def transit_mode
        case mode_type
        when 'rail'
          'rail'
        when 'bus'
          'bus'
        end
      end

      def mode
        case mode_type
        when 'walk'
          Mode::Walking
        when 'bike'
          Mode::Bicycling
        when 'drive'
          Mode::Driving
        else
          # fallback for train, bus, transit
          Mode::Transit
        end
      end
    end

    QUERY_REGEX = /^(?:(?<mode_type>#{Query::MODES.join('|')}) )?(?<start>.+) to (?<destination>.+)$/i.freeze
    def build_query
      result = arg_text.match(QUERY_REGEX)
      return nil unless result

      options = {
        start: result[:start],
        destination: result[:destination]
      }

      options[:mode_type] = result[:mode_type] if result[:mode_type]

      Query.new(**options)
    end

    class RoutePresenter
      extend T::Sig

      sig { returns(Google::Maps::Route) }
      attr_reader :route

      sig { returns(Mode) }
      attr_reader :mode

      sig { params(route: Google::Maps::Route, mode: Mode).void }
      def initialize(route, mode:)
        @route = route
        @mode = mode
      end

      sig { returns(String) }
      def to_text
        parts = [header]
        parts += route.steps.map { |step| Leg.new(step).to_text }

        parts = if mode == Mode::Transit
                  parts.join("\n\n")
                else
                  parts.join("\n")
                end

        parts.strip
      end

      private

      class Leg
        extend T::Sig

        sig { returns(Google::Maps::Result) }
        attr_reader :result

        sig { params(result: Google::Maps::Result).void }
        def initialize(result)
          @result = result
        end

        sig { returns(String) }
        def to_text
          if result.travel_mode == 'TRANSIT'
            transit = result.transit_details
            line = transit.line
            agency = line.agencies.first&.name

            <<~MSG.strip
              #{nohtml(result.html_instructions)} (#{result.duration.text})
              1. Board #{line.short_name} (#{agency}) from #{transit.departure_stop.name} at #{transit.departure_time.text}
              2. Get off at #{transit.arrival_stop.name} at #{transit.arrival_time.text}
            MSG
          else
            parts = [
              "#{instructions_for(result.html_instructions)} (#{result.duration.text})",
              steps
            ].compact

            parts.join("\n")
          end
        end

        private

        sig { returns(T.nilable(String)) }
        def steps
          return nil unless result.steps

          result
            .steps
            .map.with_index do |step, index|
              num = index + 1

              "#{num}. #{instructions_for(step.html_instructions)} "\
                "(#{step.distance.text}, #{step.duration.text})"
            end
            .join("\n")
        end

        sig { params(instructions: String).returns(String) }
        def instructions_for(instructions)
          nohtml(instructions)
            .gsub('Destination will', '. Destination will')
            .gsub('Pass by', '. Pass by')
            .gsub(/&[^;]+;/, '')
        end

        sig { params(str: String).returns(String) }
        def nohtml(str)
          str.gsub(%r{</?[^>]*>}, '')
        end
      end

      sig { returns(String) }
      def header
        <<~HEADER.strip
          #{route.duration.text} (#{route.distance.text}) to #{route.end_address}
        HEADER
      end
    end
  end
end
