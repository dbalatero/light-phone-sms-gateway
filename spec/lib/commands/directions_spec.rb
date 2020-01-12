# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/commands/directions'

RSpec.describe Commands::Directions::RoutePresenter do
  describe '#to_text' do
    context 'bike directions' do
      it 'should format the full set of directions' do
        VCR.use_cassette 'directions_bicycling', record: :once do
          route = Google::Maps.route(
            'Smith Tower, Seattle, WA',
            'University of Washington, Seattle, WA',
            mode: 'bicycling'
          )

          presenter = described_class.new(
            route,
            mode: Commands::Directions::Mode::Bicycling
          )

          expect(presenter.to_text).to eq <<~MSG.strip
            32 mins (4.5 mi) to Seattle, WA 98195, USA
            Head northwest on 2nd Ave toward James St (7 mins)
            Turn right onto Pike St. Pass by Starbucks (on the right) (7 mins)
            Turn left onto Melrose Ave (1 min)
            Slight right after Starbucks Reserve Roastery (on the left) (5 mins)
            Continue onto Melrose Trail (1 min)
            Continue onto Lakeview Blvd E (3 mins)
            Turn left onto E Newton St (1 min)
            Turn right onto Franklin Ave E (2 mins)
            Turn left onto E Louisa St (1 min)
            Turn right onto Eastlake Ave E (6 mins)
            Turn right onto NE Campus Pkwy. Destination will be on the right (1 min)
          MSG
        end
      end
    end

    context 'walking directions' do
      it 'should format the full set of directions' do
        VCR.use_cassette 'directions_walking', record: :once do
          route = Google::Maps.route(
            'Smith Tower, Seattle, WA',
            'University of Washington, Seattle, WA',
            mode: 'walking'
          )

          presenter = described_class.new(
            route,
            mode: Commands::Directions::Mode::Walking
          )

          expect(presenter.to_text).to eq <<~MSG.strip
            1 hour 30 mins (4.2 mi) to Seattle, WA 98195, USA
            Head northwest on 2nd Ave toward James St (1 min)
            Turn right onto James St (19 mins)
            Turn left onto Broadway (5 mins)
            Turn right onto E Madison St. Pass by Trader Joe's (on the left in 0.6mi) (22 mins)
            Turn left onto 23rd Ave E (12 mins)
            Slight right onto Turner Way E (1 min)
            Continue onto 24th Ave E (8 mins)
            Slight left to stay on 24th Ave E (11 mins)
            Continue onto E Montlake Pl E (1 min)
            Slight right to stay on E Montlake Pl E (1 min)
            Sharp right onto E Roanoke St (1 min)
            Turn left toward 24th Ave E (1 min)
            Turn right toward 24th Ave E (1 min)
            Turn left onto 24th Ave E (1 min)
            Turn left onto E Lake Washington Blvd (1 min)
            Turn right onto 520 Trail (2 mins)
            Turn left toward E Hamlin St (1 min)
            Turn left toward E Hamlin St (1 min)
            Turn left onto E Hamlin St (3 mins)
            Turn right onto Montlake Blvd E. Destination will be on the right (3 mins)
          MSG
        end
      end
    end

    context 'transit directions' do
      it 'should format the full set of directions' do
        VCR.use_cassette 'directions_transit', record: :once do
          route = Google::Maps.route(
            'Smith Tower, Seattle, WA',
            'University of Washington, Seattle, WA',
            mode: 'transit'
          )

          presenter = described_class.new(
            route,
            mode: Commands::Directions::Mode::Transit
          )

          expect(presenter.to_text).to eq <<~MSG.strip
            18 mins (4.4 mi) to Seattle, WA 98195, USA

            Walk to Pioneer Square Station (3 mins)
            1. Head northwest on 2nd Ave toward James St (213 ft, 1 min)
            2. Turn right onto James St (322 ft, 2 mins)
            3. Turn left onto 3rd Ave. Destination will be on the right (157 ft, 1 min)

            Light rail towards University Of Washington Station (11 mins)
            1. Board Link light rail (Sound Transit) from Pioneer Square Station at 1:15pm
            2. Get off at University of Washington Station at 1:26pm

            Walk to Seattle, WA 98195, USA (4 mins)
            1. Head south (85 ft, 1 min)
            2. Turn right toward Montlake Blvd NE (220 ft, 1 min)
            3. Turn left onto Montlake Blvd NE. Destination will be on the right (0.1 mi, 2 mins)
          MSG
        end
      end
    end
  end
end
