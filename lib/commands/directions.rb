# typed: strong
# frozen_string_literal: true

require 'google-maps'
require_relative './base'

Google::Maps.configure do |config|
  config.authentication_mode = Google::Maps::Configuration::API_KEY
  config.api_key = ENV['GOOGLE_MAPS_API_KEY']
end

module Commands
  class Directions < Base
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

      class Mode < T::Enum
        enums do
          Bicycling = new
          Walking = new
          Transit = new
        end
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
