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
      puts "%%%% OPTS = #{opts}"
      @client.request(verb, path, opts, &block)
    end
    
    def options=(opts)
      @options = opts
    end
  end
end

INSTANCE_URL = ENV['salesforce_instance_url']
SALESFORCE_OPTIONS = {:mode => :header, :header_format => 'OAuth %s'}

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

enable :sessions

def showAccounts access_token 
  response = access_token.get("#{INSTANCE_URL}/services/data/v20.0/query/?q=#{CGI::escape('SELECT Name, Id from Account LIMIT 100')}", :headers => {'Content-type' => 'application/json'}).parsed

  output = '<ul>'
  response['records'].each do |record| 
    output += "<li>#{record['Id']}, #{record['Name']}, <a href='/account/#{record['Id']}.json'>Show</a>, <a href='/account/edit/#{record['Id']}'>Edit</a></li>, <a href='/account/delete/#{record['Id']}'>Delete</a></li>"
  end
  output += '</ul>'
end

def createAccount access_token, name
  response = access_token.post("#{INSTANCE_URL}/services/data/v20.0/sobjects/Account/", :body =>"{\"Name\": \"#{name}\"}", :headers => {'Content-type' => 'application/json'}).parsed

  response['id']
end

def showAccount access_token, id
  response = access_token.get("#{INSTANCE_URL}/services/data/v20.0/sobjects/Account/#{id}", :headers => {'Content-type' => 'application/json'}).parsed

  output = '<ul>'
  response.each do |key, value|
    output += "<li>#{key}:#{value.inspect}</li>"
  end
  output += '</ul>'
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
  if session.has_key? 'access_token'
    redirect '/oauth/callback'
  else
    redirect client.auth_code.authorize_url(
      :response_type => 'code',
      :redirect_uri => "https://salesforce-demo.cloudfoundry.com/oauth/callback"
    )
  end
end

get '/accounts' do
  unless session.has_key? 'access_token'
     redirect '/oauth'
  end
  output = "<html><body><a href='/accounts.json'>JSON</a><br /><tt>"
  access_token = OAuth2::AccessToken.new(client, session['access_token'], SALESFORCE_OPTIONS.clone)
  output += showAccounts access_token 
  output += '<tt></body></html>'
end

get '/accounts.json' do
  unless session.has_key? 'access_token'
     redirect '/oauth'
  end
  access_token = OAuth2::AccessToken.new(client, session['access_token'], SALESFORCE_OPTIONS.clone)
  response = access_token.get("#{INSTANCE_URL}/services/data/v22.0/query/?q=#{CGI::escape('SELECT Name, Id from Account LIMIT 100')}", :headers => {'Content-type' => 'application/json'})
  response.body
end

get '/account/:account_id.json' do
  unless session.has_key? 'access_token'
     redirect '/oauth'
  end
  access_token = OAuth2::AccessToken.new(client, session['access_token'], SALESFORCE_OPTIONS.clone)
  response = access_token.get("#{INSTANCE_URL}/services/data/v22.0/sobjects/Account/#{@account_id}", :headers => {'Content-type' => 'application/json'})
  response.body
end

get '/accounts/create' do
  unless session.has_key? 'access_token'
     redirect '/oauth'
  end
  output = '<html><body><tt>'
  access_token = OAuth2::AccessToken.new(client, session['access_token'], SALESFORCE_OPTIONS.clone)
  if (params.has_key? 'name')
    id = createAccount access_token, params['name']
  end
  output += '<tt></body></html>'
end

get '/account/edit/:account_id' do
  unless session.has_key? 'access_token'
     redirect '/oauth'
  end
  output = '<html><body><tt>'
  access_token = OAuth2::AccessToken.new(client, session['access_token'], SALESFORCE_OPTIONS.clone)
   if (params.has_key? 'name')
     output += updateAccount access_token, @account_id, params['name'] + ', Inc', 'San Francisco'
  end
  output += showAccount access_token, @account_id
  output += '<tt></body></html>'
end

get '/account/delete/:account_id' do
  unless session.has_key? 'access_token'
     redirect '/oauth'
  end
  output = '<html><body><tt>'
  access_token = OAuth2::AccessToken.new(client, session['access_token'], SALESFORCE_OPTIONS.clone)
  output += deleteAccount access_token, @account_id
  output += '<tt></body></html>'
end

get '/oauth/callback' do
  name = 'My New Org'

  output = '<html><body><tt>'
    if session.has_key? 'access_token'
      access_token = OAuth2::AccessToken.new(client, session['access_token'], SALESFORCE_OPTIONS.clone)
    else
      access_token = client.auth_code.get_token(params[:code], :redirect_uri => "https://salesforce-demo.cloudfoundry.com/oauth/callback", :grant_type => 'authorization_code')
      session['access_token'] = access_token.token
      access_token.options = SALESFORCE_OPTIONS.clone
    end

    output += "<ul><li><a href='/accounts'>Accounts</a></li></ul>"

  output += '<tt></body></html>'
end
