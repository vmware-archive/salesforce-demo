get '/accounts' do
  @controller = 'accounts'
  @object_type = 'account'
  @data = show_all 'account'
  @record_title = "Accounts"
  haml :show_all
end

get '/accounts.json' do
  response = show_all 'account', {:raw => true}
  response
end

get '/account/:account_id' do |account_id|
  @object_type = 'account'
  @item_id = account_id
  @item_data = show_one 'account', account_id
  @record_title = @item_data['Name']
  haml :show_one
end

get '/account/raw/:account_id.json' do |account_id|
  response = show_one 'account', account_id, {:raw => true}
  response
end

get '/accounts/create' do
  @title = "Account Creation"
  @messages = []
  @cart.each do |company|
    contact_info = company['locations']['all'][0]['contact_info']
    address = company['locations']['all'][0]['address']
    # Mapping LinkedIn Companies to Salesforce Accounts
    account = {
        'Name' => "#{company['name']}",
        'Description' => "#{company['description']}",
        'TickerSymbol' => "#{company['ticker']}",
        'NumberOfEmployees' => company['employee_count_range']['name'].to_i,
        'Website' => company['website_url'],
        'Phone' => contact_info['phone1'],
        'Industry' => company['industry'],
        'Fax' => contact_info['fax'],
        'BillingStreet' => address['street1'],
        'BillingCity' => address['city'],
        'BillingState' => address['region'],
        'BillingPostalCode' => address['postal_code']
    }
    id = create 'account', account.to_json
    @messages << "Created account <a href='/account/#{id}'>#{id}</a>"
  end

  haml :info
end

get '/account/delete/:account_id' do |account_id|
  @messages = []
  if (account_id)
    delete('account', account_id)
    @messages << "Deleted #{account_id}"
  else
    @messages << request.inspect
  end
  haml :info
end


