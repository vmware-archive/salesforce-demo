require 'rubygems'
require 'sinatra'
require 'oauth2'
require 'json'
require 'cgi'
require 'net/https'

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

INSTANCE_URL = 'https://na9.salesforce.com'
OPTIONS = {:mode => :header, :header_format => 'OAuth %s'}

def client
  OAuth2::Client.new(
    '3MVG9y6x0357Hled43uoiWgfZ.8DWvMK3vZmbf6HCm_gBYFaHD6ZfPQA5SPUSNFsXfWNXcWqWet8iAxBT.UKP', 
    '3746757173514830663', 
    :site => INSTANCE_URL,
    :authorize_url =>'/services/oauth2/authorize', 
    :token_url => '/services/oauth2/token',
    :ssl=>{
    :verify=>false
    }
  )
end


def showAccounts access_token 
  response = access_token.get("#{INSTANCE_URL}/services/data/v20.0/query/?q=#{CGI::escape('SELECT Name, Id from Account LIMIT 100')}", :headers => {'Content-type' => 'application/json'}).parsed

  output = ''
  response['records'].each do |record| 
    output += "#{record['Id']}, #{record['Name']}<br/>"
  end
  output += '<br/>'
end

def createAccount access_token, name
  response = access_token.post("#{INSTANCE_URL}/services/data/v20.0/sobjects/Account/", :body =>"{\"Name\": \"#{name}\"}", :headers => {'Content-type' => 'application/json'}).parsed

  response['id']
end

def showAccount access_token, id
  response = access_token.get("#{INSTANCE_URL}/services/data/v20.0/sobjects/Account/#{id}").parsed

  output = ''
  response.each do |key, value|
    output += "#{key}:#{value}<br/>"
  end
  output += '<br/>'
end

def updateAccount access_token, id, new_name, city
  access_token.post("#{INSTANCE_URL}/services/data/v20.0/sobjects/Account/#{id}?_HttpMethod=PATCH", :body => "{\"Name\":\"#{new_name}\",\"BillingCity\":\"#{city}\"}", :headers => {'Content-type' => 'application/json'})

  'Updated record<br/><br/>'
end

def deleteAccount access_token, id
  access_token.delete("#{INSTANCE_URL}/services/data/v20.0/sobjects/Account/#{id}")

  'Deleted record<br/><br/>'
end

get '/' do
"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
<html>
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">
<title>REST/OAuth Example</title>
</head>
<body>
<script type=\"text/javascript\" language=\"javascript\">
	if (location.protocol != \"https:\") {
		document.write(\"OAuth will not work correctly from plain http. \"+
				\"Please use an https URL.\");
	} else {
		document.write(\"<a href=\\\"oauth\\\">Click here to retrieve contacts from Salesforce via REST/OAuth.</a>\");
	}
</script>
</body>
</html>"
end

get '/oauth' do
  redirect client.auth_code.authorize_url(
    :response_type => 'code',
    :redirect_uri => "https://salesforce-demo.cloudfoundry.com/oauth/callback"
  )
end

get '/oauth/callback' do
  name = 'My New Org'

  output = '<html><body><tt>'
    access_token = client.auth_code.get_token(params[:code], :redirect_uri => "https://salesforce-demo.cloudfoundry.com/oauth/callback", :grant_type => 'authorization_code')
    access_token.options = OPTIONS
    
    begin
      output += showAccounts access_token    
      id = createAccount access_token, name
      output += "Created record #{id}<br/><br/>"
      output += showAccounts access_token
      output += showAccount access_token, id
      output += updateAccount access_token, id, name + ', Inc', 'San Francisco'
      output += showAccount access_token, id
      output += showAccounts access_token
      output += deleteAccount access_token, id
      output += showAccounts access_token
    rescue OAuth2::Error => e
      output += e.response.parsed.inspect 
    end

  output += '<tt></body></html>'
end
