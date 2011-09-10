get '/opportunities' do
  @controller = 'opportunities'
  @object_type = 'opportunity'
  @data = show_all 'opportunity'
  @record_title = "Opportunities"
  haml :show_all
end

get '/opportunities.json' do
  response = show_all 'opportunity', {:raw => true}
  response
end

get '/opportunity/:opportunity_id' do |opportunity_id|
  @object_type = 'opportunity'
  @item_id = opportunity_id
  @item_data = show_one 'opportunity', opportunity_id
  @record_title = @item_data['Name']
  haml :show_one
end

get '/opportunity/raw/:opportunity.json' do |opportunity_id|
  response = show_one 'opportunity', opportunity_id, {:raw => true}
  response
end

get '/opportunity/raw/:opportunity_id.json' do |opportunity_id|
  response = show_one 'opportunity', opportunity_id, {:raw => true}
  response
end

get '/opportunities/create' do
  @messages = []
  i = 0
  @cart.each do |company|
    contact_info = {}
    address = {}
    if (company['locations']['all'].count > 0)
      contact_info = company['locations']['all'][0]['contact_info']
      address = company['locations']['all'][0]['address']
    end
    # Mapping LinkedIn Companies to Salesforce Opps
    opp = {
        'Name' => "#{company['name']} Enterprise Licenses",
        'Description' => "#{company['description']}",
        'CloseDate' => "2012-#{(i % 12).to_s}-15",
        'StageName' => 'Negotiation/Review'
    }
    id = create 'opportunity', opp.to_json
    @messages << "Created opportunity <a href='/opportunity/#{id}.json'>#{id}</a>"
    i += 1
  end

  haml :info
end

post '/opportunities/delete' do
  @messages = []
  @data = show_all 'opportunity'
  @data.each do |opp|
    delete('opportunity', opp['Id'])
    @messages << "Deleted #{opp['Id']}"
  end
  haml :info
end

get '/opportunity/delete/:opportunity_id' do |opportunity_id|
  @messages = []
  if (opportunity_id)
    delete('opportunity', opportunity_id)
    @messages << "Deleted #{opportunity_id}"
  else
    @messages << request.inspect
  end
  haml :info
end


