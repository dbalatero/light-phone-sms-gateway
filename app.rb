# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require_relative './lib/compare'

class App < Sinatra::Base
  get '/' do
    body 'OK'
  end

  post '/gateway' do
    secret_token = request.env['SmsGatewayToken']
    configured_token = ENV.fetch('GATEWAY_SECRET_KEY')

    if Compare.secure_compare(secret_token, configured_token)
      body 'OK GATEWAY'
    else
      # forbidden
      return status 403
    end
  end
end
