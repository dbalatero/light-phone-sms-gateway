# typed: strict
# frozen_string_literal: true

require_relative './base'

module Commands
  class Tip < Base
    extend T::Sig

    sig { override.returns(String) }
    def self.name
      'tip'
    end

    sig { override.returns(String) }
    def self.help
      <<~HELP
        tip <percentage> <amount>: returns the tip amount
        based on the bill amount and the tip percentage
        (<amount> * <percentage> / 100).

        Example: tip 1234.56 20
        Returns: Tip: 246.91
      HELP
    end

    sig { override.returns(String) }
    def response_body
      matches = arg_text.match(/^(?<percentage>([1-9]\d*|0)(\.\d+)?)\s+(?<amount>([1-9]\d*|0)(\.\d+)?)$/)

      return help unless matches

      amount = matches[:amount].to_f
      percentage = matches[:percentage].to_f

      result = (amount * percentage / 100).round(2)

      "Tip: #{'%.2f' % result}"
    end
  end
end
