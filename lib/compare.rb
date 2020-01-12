# typed: false
# frozen_string_literal: true

module Compare
  extend T::Sig

  module_function

  # File activesupport/lib/active_support/security_utils.rb, line 11
  sig { params(a: String, b: String).returns(Boolean) }
  def fixed_length_secure_compare(a, b)
    unless a.bytesize == b.bytesize
      raise ArgumentError, 'string length mismatch.'
    end

    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end

  # File activesupport/lib/active_support/security_utils.rb, line 26
  sig { params(a: String, b: String).returns(Boolean) }
  def secure_compare(a, b)
    fixed_length_secure_compare(
      ::Digest::SHA256.digest(a),
      ::Digest::SHA256.digest(b)
    ) && a == b
  end
end
