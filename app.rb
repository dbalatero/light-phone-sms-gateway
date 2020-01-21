# typed: ignore
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'sorbet-runtime'
require 'sinatra/base'
require 'twilio-ruby'

require_relative './lib/compare'
require_relative './lib/commands'
require_relative './lib/phone_whitelist'

class App < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  get '/' do
    body 'OK'
  end

  post '/gateway' do
    incoming_message = params['Body'].to_s.downcase
    cmd, arg_text = incoming_message.split(/\s+/, 2)
    whitelist = PhoneWhitelist.new(ENV['SENDER_WHITELIST'])
    twiml = Twilio::TwiML::MessagingResponse.new

    logger.info "Received command: #{cmd}, arg text: #{arg_text}"

    if whitelist.valid_number?(params['From'])
      command_class = Commands.get(cmd) || Commands::Help
      command = command_class.new(arg_text)

      twiml.message do |message|
        message.body(command.response_body)
      end
    else
      logger.info "The sender is not whitelisted"
    end

    twiml.to_s
  end
end
