# typed: ignore
# frozen_string_literal: true

module Commands
  class Base
    extend T::Sig

    sig { params(_arg_text: T.nilable(String)).void }
    def initialize(_arg_text = nil); end

    sig { abstract.returns(String) }
    def self.name; end

    sig { abstract.returns(String) }
    def response_body; end
  end
end
