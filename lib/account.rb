get '/accounts' do
  @controller = 'accounts'
  @data = show_all 'account'
  @title = "Accounts"
  haml :show_all
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
    account = {'Name' => "#{params['name']} #{i}"}
    id = create 'account', account.to_json
    output += "Created account <a href='/account/#{id}.json'>Account ID=#{id}</a><br />"
  end

  output += '<tt></body></html>'
end

get '/account/edit/:account_id' do |account_id|
  output = '<html><body><tt>'
   if (params.has_key? 'name' && params['name'] )
     account = {'Name' => params['name']}
     output += update 'account', account_id, account.to_json
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


