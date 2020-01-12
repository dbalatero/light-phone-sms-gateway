# typed: ignore
# frozen_string_literal: true

module Commands
  class Base
    extend T::Sig

    sig { returns(String) }
    attr_reader :arg_text

    sig { params(arg_text: T.nilable(String)).void }
    def initialize(arg_text = nil)
      @arg_text = arg_text.to_s
    end

    sig { abstract.returns(String) }
    def self.name; end

    sig { abstract.returns(String) }
    def self.help; end

    sig { abstract.returns(String) }
    def response_body; end

    sig { returns(String) }
    def help
      self.class.help
    end
  end
end
