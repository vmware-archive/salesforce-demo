require_relative "oauth2_patch"
require_relative "salesforce"
require_relative "chatter"
require_relative "linkedin_client"
require_relative "helpers"
require_relative "opportunity"
require_relative "account"
require_relative "lead"
require_relative "company"
require_relative "person"

require "logger"

module SalesforceDemo
  class Config
    class << self
      attr_accessor :logger, :host, :redis

      def init
        @logger = Logger.new(STDOUT)
        @cf_env =  CloudFoundry::Environment
        @host = "https://#{@cf_env.first_url || '127.0.0.1:4567'}"
        @logger.info("Host is #{@host}")
        @redis = Redis.new({:host => "127.0.0.1", :port => "6379"})
      end
    end
  end
end