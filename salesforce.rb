INSTANCE_URL = ENV['salesforce_instance_url']
SALESFORCE_OPTIONS = {:mode => :header, :header_format => 'OAuth %s'}

def get_access_token code
  session['salesforce_access_token'] = client.auth_code.get_token(code, :redirect_uri => "https://salesforce-demo.cloudfoundry.com/oauth/callback", :grant_type => 'authorization_code').token
end

def access_token
  if session.has_key? 'salesforce_access_token'
    return OAuth2::AccessToken.new(client, session['salesforce_access_token'], SALESFORCE_OPTIONS.clone)
  else
    session['url'] = request.path
    redirect client.auth_code.authorize_url(
      :response_type => 'code',
      :redirect_uri => "https://salesforce-demo.cloudfoundry.com/oauth/callback"
    )
  end
end

def client
  OAuth2::Client.new(
    ENV['salesforce_key'],
    ENV['salesforce_secret'],
    :site => INSTANCE_URL,
    :authorize_url =>'/services/oauth2/authorize',
    :token_url => '/services/oauth2/token',
    :ssl=>{
    :verify=>false
    }
  )
end

def show_all object_type, options={}
  begin
    response = access_token.get("#{INSTANCE_URL}/services/data/v20.0/query/?q=#{CGI::escape("SELECT Name, Id from #{object_type.capitalize} LIMIT 100")}", :headers => {'Content-type' => 'application/json'})
     output = nil
     if (options[:raw] == true)
      return response.body
     elsif (response.parsed['records'].count > 0)
      output = '<ul>'
      response.parsed['records'].each do |record|
        output += "<li>#{record['Id']}, #{record['Name']}, <a href='/#{object_type}/#{record['Id']}'>Show</a>, <a href='/#{object_type}/edit/#{record['Id']}'>Edit</a>, <a href='/#{object_type}/delete/#{record['Id']}'>Delete</a></li>"
      end
      output += '</ul>'
    end
  rescue OAuth2::Error => e
      e.response.inspect
  end
  output
end

def create object_type, json
  begin
    response = access_token.post("#{INSTANCE_URL}/services/data/v20.0/sobjects/#{object_type.capitalize}/", :body =>json, :headers => {'Content-type' => 'application/json'}).parsed
    return response['id']
  rescue OAuth2::Error => e
    return e.response.inspect
  end
end

def show_one object_type, id, options={}
  begin
    response = access_token.get("#{INSTANCE_URL}/services/data/v20.0/sobjects/#{object_type.capitalize}/#{id}", :headers => {'Content-type' => 'application/json'})

    if (options[:raw] == true)
      return response.body
    else
      response_parsed = response.parsed
      output = '<ul>'
      response_parsed.each do |key, value|
        output += "<li>#{key}:#{value}</li>" unless value.nil?
      end
      output += '</ul>'
      return output
    end
  rescue OAuth2::Error => e
     return e.response.inspect
  end
end

def update object_type, id, json

  begin
    access_token.post("#{INSTANCE_URL}/services/data/v20.0/sobjects/#{object_type.capitalize}/#{id}?_HttpMethod=PATCH", :body => json, :headers => {'Content-type' => 'application/json'})
    'Updated record<br/><br/>'
  rescue OAuth2::Error => e
      e.response.inspect
  end
end

def delete object_type, id
  begin
    access_token.delete("#{INSTANCE_URL}/services/data/v20.0/sobjects/#{object_type}/#{id}")
    'Deleted record<br/><br/>'
  rescue OAuth2::Error => e
      e.response.inspect
  end
end
