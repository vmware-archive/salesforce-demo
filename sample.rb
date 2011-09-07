require 'rubygems'
require 'sinatra'
require 'oauth2'
require 'json'
require 'cgi'
require 'net/https'
require 'oauth2'
require_relative 'oauth2_patch'
require_relative 'salesforce'
require_relative 'opportunity'
require_relative 'Account'
require_relative 'Lead'
require 'linkedin'
require_relative 'linkedin_client'
require_relative 'Company'
enable :sessions

get '/' do
  @cart = []
  if (session[:recent_companies])
    session[:recent_companies].each do |key, json|
      @cart << JSON::parse(json)
    end
  end
  haml :index
end

get '/oauth/callback' do
  get_access_token params[:code] if (params[:code])
  redirect session['url'] || '/'
end

