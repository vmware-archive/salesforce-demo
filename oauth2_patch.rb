module OAuth2
  class Client
    def get_token(params, access_token_opts={})
      opts = {:raise_errors => true, :parse => params.delete(:parse)}
      if options[:token_method] == :post
        opts[:body] = params
        opts[:headers] =  {'Content-Type' => 'application/x-www-form-urlencoded'}
      else
        opts[:params] = params
      end
      response = request(options[:token_method], token_url, opts)
      raise Error.new(response) unless response.parsed.is_a?(Hash) && response.parsed['access_token']
      at = AccessToken.from_hash(self, response.parsed.merge(access_token_opts))
      at.instance_url = response.parsed['instance_url']
      return at
    end
  end
  class AccessToken
    attr_accessor :instance_url

    def request(verb, path, opts={}, &block)
      set_token(opts)
      @client.request(verb, path, opts, &block)
    end

    def options=(opts)
      @options = opts
    end
  end
end