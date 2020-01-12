# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/commands/ping'

RSpec.describe Commands::Ping do
  describe '.name' do
    it { expect(described_class.name).to eq('ping') }
  end

  describe '#response_body' do
    it 'should respond with pong' do
      command = Commands::Ping.new
      expect(command.response_body).to eq('pong')
    end
  end
end
