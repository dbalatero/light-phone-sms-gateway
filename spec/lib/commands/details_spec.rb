# typed: ignore
# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/commands/details'

RSpec.describe Commands::Details do
  describe '#response_body' do
    it 'should return details about the place if there is a single result' do
      VCR.use_cassette 'details_single', record: :once do
        command = Commands::Details.new('naru victoria bc')

        expect(command.response_body).to eq <<~MSG.strip
          NARU Korean Restaurant
          1218 Wharf St, Victoria, BC V8W 1T8, Canada
          Phone: (250) 590-5298
          Rating: 4.5
          Open now
          Hours:
          * Monday: 11:30 AM – 4:00 PM, 5:00 – 9:30 PM
          * Tuesday: 11:30 AM – 4:00 PM, 5:00 – 9:30 PM
          * Wednesday: 11:30 AM – 4:00 PM, 5:00 – 9:30 PM
          * Thursday: 11:30 AM – 4:00 PM, 5:00 – 9:30 PM
          * Friday: 11:30 AM – 4:00 PM, 5:00 – 9:30 PM
          * Saturday: 11:30 AM – 4:00 PM, 5:00 – 9:30 PM
          * Sunday: Closed
        MSG
      end
    end

    it 'should return a list of at most 10 places if there are multiple results' do
      VCR.use_cassette 'details_multiple', record: :once do
        command = Commands::Details.new('korean restaurant, victoria bc')

        expect(command.response_body).to eq <<~MSG.strip
          (1) NARU Korean Restaurant, Wharf Street, Victoria, BC, Canada
          (2) Cera Korean Restaurant, Pandora Avenue, Victoria, BC, Canada
          (3) Han Korean Restaurant, Johnson Street, Victoria, BC, Canada
          (4) Sura Korean Restaurant, Douglas Street, Victoria, BC, Canada
          (5) Sumi Korean Restaurant, Victoria Drive, Vancouver, BC, Canada
        MSG
      end
    end

    it 'should return an error message if the place does not exist' do
      VCR.use_cassette 'details_not_found', record: :once do
        arg = '00000000000000000000'
        command = Commands::Details.new(arg)
        expect(command.response_body).to eq("NO RESULTS FOR \"#{arg}\"")
      end
    end

    it 'should return help for a malformed request' do
      command = Commands::Details.new('')
      expect(command.response_body).to eq(Commands::Details.help)
    end
  end
end