# typed: ignore
# frozen_string_literal: true

require 'spec_helper'
require_relative "../../../lib/commands/tip"

describe Commands::Tip do
  describe "#response_body" do
    it "should calculate a percentage tip" do
      command = Commands::Tip.new("20 100.00")
      expect(command.response_body).to eq("Tip: 20.00")
    end

    it "should return help for a malformed response" do
      command = Commands::Tip.new("20")
      expect(command.response_body).to eq(Commands::Tip.help)
    end
  end
end