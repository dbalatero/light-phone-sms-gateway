# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    body 'OK'
  end

  post '/gateway' do
    body 'OK GATEWAY'
  end
end
