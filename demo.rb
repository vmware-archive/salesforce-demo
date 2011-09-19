require 'rubygems'
require 'sinatra'
require 'oauth2'
require 'json'
require 'cgi'
require 'net/https'
require 'oauth2'
require 'linkedin'
require 'redis'

require_relative 'oauth2_patch'
require_relative 'salesforce'
require_relative 'lib/chatter'
require_relative 'linkedin_client'
require_relative 'lib/helpers'
require_relative 'lib/opportunity'
require_relative 'lib/account'
require_relative 'lib/lead'
require_relative 'lib/company'
require_relative 'lib/person'

enable :sessions

configure do
  services = JSON.parse(ENV['VCAP_SERVICES'])
    redis_key = services.keys.select { |svc| svc =~ /redis/i }.first
    redis = services[redis_key].first['credentials']
    redis_conf = {:host => redis['hostname'], :port => redis['port'], :password => redis['password']}
    @@redis = Redis.new redis_conf
    @@redis.flushdb
    #puts "REDIS INFO: #{@@redis.info}"
end

before do
  @title = "Salesforce Demo Builder"
  @cart = []
  redis_data = @@redis.smembers cart_id
  if (redis_data)
    redis_data.each do |key|
      json = @@redis.get key
      @cart << JSON.parse(json)
    end
  end
  @search_term = @@redis.get search_id
end

get '/' do
  haml :index
end

get '/oauth/callback' do
  get_access_token params[:code] if (params[:code])
  redirect session['url'] || '/'
end

get '/salesforce/instance' do
  @access_token = session['salesforce_access_token']
  @my_url = instance
  haml :salesforce_instance
end

post '/salesforce/instance' do
  if (params['url'] && params['url']!= session['salesforce_instance_url'])
    @my_old_url = session['salesforce_instance_url']  || 'na1'
    session.delete 'salesforce_access_token'
    session['salesforce_instance_url'] = params[:url]
    @access_token = ''
    @message = "Saved"
  end
  @my_url = instance
  haml :salesforce_instance
end

def cart_id
 return "session_#{request.session_options[:id]}_cart"
end

def search_id
 return "session_#{request.session_options[:id]}_search"
end

