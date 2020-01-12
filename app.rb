# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'sorbet-runtime'

require 'sinatra/base'
require_relative './lib/compare'

class App < Sinatra::Base
  get '/' do
    body 'OK'
  end

  post '/gateway' do
    secret_token = request.env['HTTP_SMS_GATEWAY_TOKEN']
    return status 403 unless secret_token

    configured_token = ENV.fetch('GATEWAY_SECRET_KEY')
    return status 403 unless Compare.secure_compare(secret_token, configured_token)

    body 'OK GATEWAY'
  end
end
