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
    domains = nil
    begin
      domains = company['email_domains']['all']
    rescue
    end
    contact_info = {}
    address = {}
    if (company['locations'] && company['locations']['all'] && company['locations']['all'].count > 0)
      contact_info = company['locations']['all'][0]['contact_info']
      address = company['locations']['all'][0]['address']
    end
    gen = PersonGenerator.new (domains)
    person = gen.next_person
    lead = {
        'FirstName' => person.first_name,
        'LastName' =>person.last_name,
        'Email' => person.email,
        'Company' => company['name'],
        'Website' => company['website_url'],
        'Industry' => company['industry'],
        'Phone' => contact_info['phone1'],
        'Street' => address['street1'],
        'City' => address['city'],
        'State' => address['region'],
        'PostalCode' => address['postal_code']
    }
    id = create 'lead', lead.to_json
    @messages << "Created lead <a href='/lead/#{id}'>#{id}</a>"
  end

  haml :info
end

post '/leads/delete' do
  @messages = []
  @data = show_all 'lead'
  @data.each do |lead|
    delete('lead', lead['Id'])
    @messages << "Deleted #{lead['Id']}"
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


