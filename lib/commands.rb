# typed: false
# frozen_string_literal: true

require_relative './commands/base'
require_relative './commands/directions'
require_relative './commands/help'
require_relative './commands/ping'
require_relative './commands/tip'

module Commands
  extend T::Sig

  sig { returns(T::Array[T.class_of(Commands::Base)]) }
  def self.all
    [
      Commands::Directions,
      Commands::Help,
      Commands::Ping,
      Commands::Tip
    ]
  end

  sig do
    params(command_name: String)
      .returns(T.nilable(T.class_of(Commands::Base)))
  end
  def self.get(command_name)
    all.find { |klass| klass.name == command_name }
  end
end
