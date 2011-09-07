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
require 'redis'
enable :sessions


configure do
  services = JSON.parse(ENV['VCAP_SERVICES'])
    redis_key = services.keys.select { |svc| svc =~ /redis/i }.first
    redis = services[redis_key].first['credentials']
    redis_conf = {:host => redis['hostname'], :port => redis['port'], :password => redis['password']}
    @@redis = Redis.new redis_conf
end

get '/' do
  @cart = []
  redis_data = @@redis.smembers cart_id
  if (redis_data)
    redis_data.each do |key|
      json = @@redis.get key
      @cart << JSON.parse(json)
    end
  end
  haml :index
end

get '/oauth/callback' do
  get_access_token params[:code] if (params[:code])
  redirect session['url'] || '/'
end

def cart_id
 return "session_#{request.session_options[:id]}_cart"
end

