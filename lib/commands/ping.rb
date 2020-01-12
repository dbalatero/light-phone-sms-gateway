# typed: strong
# frozen_string_literal: true

require_relative './base'

module Commands
  class Ping < Base
    extend T::Sig

    sig { override.returns(String) }
    def self.name
      'ping'
    end

    sig { override.returns(String) }
    def response_body
      'pong'
    end
  end
end
