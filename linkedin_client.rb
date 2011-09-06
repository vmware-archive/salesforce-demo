module LinkedIn
  class Client

    def parse_oauth_options
      {
        :request_token_url => full_oauth_url_for(:request_token, :api_host),
        :access_token_url  => full_oauth_url_for(:access_token,  :api_host),
        :authorize_url     => full_oauth_url_for(:authorize,     :auth_host),
        :site              => @consumer_options[:site] || @consumer_options[:api_host] || DEFAULT_OAUTH_OPTIONS[:api_host]
      }
    end

    def simple_query(path, options={})
      fields = options[:fields] || LinkedIn.default_profile_fields

      if options[:public]
        path +=":public"
      elsif fields
        path +=":(#{fields.map{ |f| f.to_s.gsub("_","-") }.join(',')})"
      end

      Mash.from_json(get(path))
    end

    def field_selector(fields)
      result = ":("
      fields.to_a.map! do |field|
        if field.is_a?(Hash)
          innerFields = []
          field.each do |key, value|
            innerFields << key.to_s.gsub("_","-") + field_selector(value)
          end
          innerFields.join(',')
        else
          field.to_s.gsub("_","-")
        end
      end
      result += fields.join(',')
      result += ")"
      result
    end

    def format_options_for_query(opts)
      opts.inject({}) do |list, kv|
        key, value = kv.first.to_s.gsub("_","-"), kv.last
        list[key]  = sanatize_value(value)
        list
      end
    end

    def sanatize_value(value)
      value = value.join("+") if value.is_a?(Array)
      value = CGI.escape(value.to_s) if value.respond_to?(:to_s)
      value
    end

    def company(options={})
      path = "/companies/"

      # retrieve companies by email domain
      if options[:email_domain]
        path = path.chomp('/') + "?email-domain=#{sanatize_value(options[:email_domain])}"
      else
        # retrieve company by id or universal name identification
        if options[:id]
          path += options[:id]
        elsif options[:universal_name]
          path += "universal-name=#{sanatize_value(options[:universal_name])}"
        end
        # define fields to retrieve
        path += field_selector(options[:fields]) if options[:fields]
      end

      Mash.from_json(get(path))
    end

    # Search for companies.
    # param:: keywords [String] Companies that have all the keywords anywhere in their listing. Multiple words should be separated by a space.
    # param:: options [Hash] A customizable set of options.
    # options:: [String] :start Start location within the result set for paginated returns. Default value is 0.
    # options:: [String] :count The number of companies to return. Default value is 10.
    # options:: [String] :order Controls the search result order (relevance, relationship, followers, company-size). Default value is relevance.
    # options:: [Array] :fields Field Selectors to retrieve the additional fields. Fields returned by default: id and name.
    # result:: [LinkedIn::Mash]
    # see:: http://developer.linkedin.com/docs/DOC-1325
    #
    def company_search(keywords, options={})
      path = "/company-search"

      fields = options.delete(:fields)
      path += field_selector(fields) if fields

      options[:keywords] = keywords
      options = format_options_for_query(options)

      result_json = get(to_uri(path, options))
      Mash.from_json(result_json)
    end
  end
end

get '/oauth1/callback' do
  pin = params[:oauth_verifier]
  if pin
    lnk_client = LinkedIn::Client.new(ENV['linkedin_key'], ENV['linkedin_secret'])
    atoken, asecret = lnk_client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
    session[:atoken] = atoken
    session[:asecret] = asecret
    puts "OAuth Got atoken #{session[:atoken]} asecret #{session[:asecret]}"
    redirect session['url'] || '/'
  end
end

def get_linkedin_client
  lnk_client = LinkedIn::Client.new(ENV['linkedin_key'], ENV['linkedin_secret'])
  if session[:atoken].nil?
    session['url'] = request.path
    request_token = lnk_client.request_token(:oauth_callback => "http://salesforce-demo.cloudfoundry.com/oauth1/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret

    redirect lnk_client.request_token.authorize_url
  else
    puts "OAuth Using atoken #{session[:atoken]} asecret #{session[:asecret]}"
    lnk_client.authorize_from_access(session[:atoken], session[:asecret])
  end
  lnk_client
end

def lnk_show_all_companies options={}
  lnk_client = get_linkedin_client
  begin
    response = lnk_client.company_search(params['q'])
    puts "RESPONSE #{response.inspect}"

    output = '<ul>'
    object_type = 'company'
    response.companies.all.each do |record|
      output += "<li>#{record.id}, #{record.name}, <a href='/#{object_type}/#{record.id}'>Show</a></li>"
    end
    output += '</ul>'

  rescue OAuth2::Error => e
      e.response.inspect
  end
end

def lnk_show_company id, options={}
  lnk_client = get_linkedin_client
  begin
    response = lnk_client.company({:id => id, :fields => ['id', 'name', 'description', 'founded-year', 'universal-name', 'locations', 'email-domains', 'company-type', 'website-url', 'ticker', 'logo-url', 'twitter-id', 'employee-count_range']})
    puts "RESPONSE #{response.inspect}"

    if (options[:raw] == true)
      return response.body
    else
      return hashie_to_ul response
    end
  rescue OAuth2::Error => e
     return e.response.inspect
  end
end

def array_to_ul array
  output = '<ul>'
  array.each do |value|
    if (value.respond_to? :keys)
      value = hashie_to_ul value
    elsif (value.class == Array)
      value = array_to_ul value
    end
    output += "<li>#{value}</li>"
  end
  output += '</ul>'
  return output
end

def hashie_to_ul hashie
  output = '<ul>'
  hashie.keys.each do |key|
    value = hashie[key]
    unless value.nil?
      if (value.respond_to? :keys)
        value = hashie_to_ul value
      elsif (value.class == Array)
        value = array_to_ul value
      end
      output += "<li><strong>#{key}</strong>: #{value}</li>"
    end
  end
  output += '</ul>'
  return output
end


