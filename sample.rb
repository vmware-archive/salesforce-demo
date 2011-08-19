require 'rubygems'
require 'sinatra'
require 'oauth2'
require 'json'
require 'cgi'
require 'net/https'
require 'salesforce'
require 'oauth2_patch'

enable :sessions

get '/' do
  output = '<html><title>Salesforce Demo</title><body><h1>Salesforce Demo</h1><tt>'
  output += "<ul><li><a href='/accounts'>Accounts</a></li></ul>"
  output += '<tt></body></html>'
end

get '/oauth/callback' do
  get_access_token params['code'] if (params['code'])
  redirect session['url'] || '/'
end

get '/accounts' do
  output = "<html><body><a href='/accounts.json'>JSON</a><br /><a href='/accounts/create?name='>New Account</a><br /><tt>"
  output += show_all 'account'
  output += '<tt></body></html>'
end

get '/accounts.json' do
  response = show_all 'account', {:raw => true}
  response
end

get '/account/:account_id' do |account_id|
  output = "<html><body><a href='/account/raw/#{account_id}.json'>JSON</a><br /><tt>"
  output += show_one 'account', account_id
  output += '<tt></body></html>'
end

get '/account/raw/:account_id.json' do |account_id|
  response = show_one 'account', account_id, {:raw => true}
  response
end

get '/accounts/create' do
  output = '<html><body><tt>'
  name = params['name'] rescue 'Acme'
  n = params['n'].to_i rescue 1
  n.times do |i|
    id = create 'account', "#{name} #{i}"
    output += "Created account <a href='/account/#{id}.json'>Account ID=#{id}</a><br />"
  end

  output += '<tt></body></html>'
end

get '/account/edit/:account_id' do |account_id|
  output = '<html><body><tt>'
   if (params.has_key? 'name' && params['name'] )
     output += update 'account', account_id, "{'Name' : '#{params['name']}'}"
     output += "Updated account <a href='/account/#{account_id}.json'>Account ID=#{account_id}</a>"
  end 
  output += '<tt></body></html>'
end

get '/account/delete/:account_id' do |account_id|
  output = '<html><body><tt>'
  if (account_id)
    output += "<p>Deleting #{account_id}</p>"
    output += delete 'account', account_id
  else
    output += request.inspect
  end
  output += '<tt></body></html>'
end


