# typed: strong
# frozen_string_literal: true

require_relative './base'

module Commands
  class Help < Base
    extend T::Sig

    sig { override.returns(String) }
    def self.name
      'h'
    end

    def self.help
      <<~HELP
        h [command]: if command is given, returns help for that command.
        Otherwise, returns a list of available commands.

        Example: help directions
      HELP
    end

    def response_body
      if command
        command.help
      else
        names = Commands.all.map(&:name).sort.join(', ')

        "Available commands: #{names}"
      end
    end

    private

    sig { returns(T.nilable(T.class_of(Commands::Base))) }
    def command
      return nil unless arg_text

      Commands.get(arg_text.strip)
    end
  end
end
