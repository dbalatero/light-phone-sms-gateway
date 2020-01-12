# typed: strong
# frozen_string_literal: true

module Commands
  class Base
    extend T::Sig

    def initialize(arg_text)
      @arg_text = arg_text
    end

    sig { abstract.returns(String) }
    def self.name; end

    sig { abstract.returns(String) }
    def response_body; end
  end
end

require_relative './commands/ping'
