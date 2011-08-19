module OAuth2
  class AccessToken
    def request(verb, path, opts={}, &block)
      set_token(opts)
      @client.request(verb, path, opts, &block)
    end

    def options=(opts)
      @options = opts
    end
  end
end