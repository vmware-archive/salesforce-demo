require 'rubygems'
require 'sinatra'
require 'oauth2'
require 'json'
require 'cgi'
require 'net/https'
require 'salesforce'
require 'oauth2_patch'
require 'opportunity.rb'
require 'Account.rb'
require 'Lead.rb'

enable :sessions

get '/' do
  haml :index
end

get '/oauth/callback' do
  get_access_token params[:code] if (params[:code])
  redirect session['url'] || '/'
end

