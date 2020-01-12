# typed: ignore
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'sorbet-runtime'
require 'sinatra/base'
require 'twilio-ruby'

require_relative './lib/compare'
require_relative './lib/commands'

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

    logger.info "Received command: #{cmd}, arg text: #{arg_text}"
    command_class = Commands.get(cmd) || Commands::Help

    twiml = Twilio::TwiML::MessagingResponse.new do |resp|
      command = command_class.new(arg_text)
      resp.message body: command.response_body
    end

    twiml.to_s
  end
end
