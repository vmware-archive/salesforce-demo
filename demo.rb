require "rubygems"
require "sinatra"
require "oauth2"
require "json"
require "cgi"
require "net/https"
require "oauth2"
require "linkedin"
require "redis"
require "cloudfoundry/environment"

require_relative "lib/salesforce_demo"

enable :sessions

configure do
  SalesforceDemo::Config.init
end

before do
  @title = "Salesforce Demo Builder"
  @cart = []
  redis_data = SalesforceDemo::Config.redis.smembers(cart_id)
  if redis_data
    redis_data.each do |key|
      json = SalesforceDemo::Config.redis.get(key)
      @cart << JSON.parse(json)
    end
  end
  @search_term = SalesforceDemo::Config.redis.get(search_id)
end

helpers do
  def cart_id
   return "session_#{request.session_options[:id]}_cart"
  end

  def search_id
   return "session_#{request.session_options[:id]}_search"
  end
end

get "/" do
  haml :index
end

get "/oauth/callback" do
  get_access_token(params[:code]) if params[:code]
  redirect session["url"] || "/"
end

get "/salesforce/instance" do
  @access_token = session["salesforce_access_token"]
  @my_url = instance
  haml :salesforce_instance
end

post "/salesforce/instance" do
  if (params["url"] and params["url"]!= session["salesforce_instance_url"])
    @my_old_url = session["salesforce_instance_url"] || "na1"
    session.delete("salesforce_access_token")

    session["salesforce_instance_url"] = params[:url]
    @access_token = ""
    @message = "Saved"
  end
  @my_url = instance
  haml :salesforce_instance
end

