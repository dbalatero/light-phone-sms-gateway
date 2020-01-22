# typed: ignore
# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/phone_whitelist'

RSpec.describe PhoneWhitelist do
  describe '#valid_number?' do
    it 'validates a phone number in the absence of a whitelist' do
      whitelist = PhoneWhitelist.new(nil)

      expect(whitelist.valid_number?('+12061234567')).to eq(true)
    end

    it 'validates a phone number against a whitelist of one' do
      whitelist = PhoneWhitelist.new('+12061234567')

      expect(whitelist.valid_number?('+12061234567')).to eq(true)
    end

    it 'does not validate a phone number that is not included in the whitelist' do
      whitelist = PhoneWhitelist.new('+12061234567 +18001234567')

      expect(whitelist.valid_number?('+18881234567')).to eq(false)
    end

    it 'validates a phone number against comma-separated numbers' do
      whitelist = PhoneWhitelist.new('+12061234567,+18001234567,+15207654321')

      expect(whitelist.valid_number?('+18001234567')).to eq(true)
    end

    it 'does not validate a phone number against non-comma-separated numbers' do
      whitelist = PhoneWhitelist.new('+12061234567 +18001234567')

      expect(whitelist.valid_number?('+18001234567')).to eq(false)
    end

    it 'validates a phone number against hyphen-containing ones' do
      whitelist = PhoneWhitelist.new('+1-800-123-4567')

      expect(whitelist.valid_number?('+18001234567')).to eq(true)
    end

    it 'does not validate a number against space-containing ones' do
      whitelist = PhoneWhitelist.new('+1 800 123 4567')

      expect(whitelist.valid_number?('+18001234567')).to eq(false)
    end

    it 'does not validate a number against parenthesis-containing ones' do
      whitelist = PhoneWhitelist.new('+1-(800)-123-4567')

      expect(whitelist.valid_number?('+18001234567')).to eq(false)
    end

    it 'does not validate a number against ones missing the area code' do
      whitelist = PhoneWhitelist.new('1234567')

      expect(whitelist.valid_number?('+18001234567')).to eq(false)
    end

    it 'does not validate a number against ones missing the country code' do
      whitelist = PhoneWhitelist.new('8001234567')

      expect(whitelist.valid_number?('+18001234567')).to eq(false)
    end

    it 'does not validate a number against ones missing the + sign' do
      whitelist = PhoneWhitelist.new('18001234567')

      expect(whitelist.valid_number?('+18001234567')).to eq(false)
    end
  end
end