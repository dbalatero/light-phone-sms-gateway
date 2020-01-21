# typed: strong
# frozen_string_literal: true

class PhoneWhitelist
  extend T::Sig

  sig { params(whitelist: T.nilable(String)).void }
  def initialize(whitelist = nil)
    @whitelist = T.let(whitelist ? whitelist.gsub('-', '').split(',') : nil, T.nilable(T::Array[String]))
  end

  sig { params(from: String).returns(T::Boolean) }
  def valid_number?(from)
    @whitelist.nil? || @whitelist.include?(from)
  end
end