get '/leads' do
  @controller = 'leads'
  @data = show_all 'lead'
  @record_title = "Leads"
  @object_type = 'lead'
  haml :show_all
end

get '/leads.json' do
  response = show_all 'lead', {:raw => true}
  response
end

get '/lead/:lead_id' do |lead_id|
  @object_type = 'lead'
  @item_id = lead_id
  @item_data = show_one 'lead', lead_id
  @record_title = @item_data['Name']
  haml :show_one
end

get '/lead/raw/:lead_id.json' do |lead_id|
  response = show_one 'lead', lead_id, {:raw => true}
  response
end

get '/leads/create' do
  @title = "Lead Creation"
  @messages = []
  @cart.each do |company|
    lead = {'FirstName' => "Trevor", 'LastName' => "Yang", 'Company' => "#{company['name']}"}
    id = create 'account', lead.to_json
    @messages << "Created lead <a href='/lead/#{id}'>#{id}</a>"
  end

  haml :info
end


get '/lead/delete/:lead_id' do |lead_id|
  @messages = []
  if (lead_id)
    delete('lead', lead_id)
    @messages << "Deleted #{lead_id}"
  else
    @messages << request.inspect
  end
  haml :info
end


