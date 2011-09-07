get '/leads' do
  @controller = 'leads'
  @data = show_all 'lead'
  @title = "Leads"
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

  haml :show_one
end

get '/lead/raw/:lead_id.json' do |lead_id|
  response = show_one 'lead', lead_id, {:raw => true}
  response
end

get '/leads/create' do
  output = '<html><body><tt>'
  name = params['name'] rescue 'Parker'
  n = params['n'].to_i rescue 1
  n.times do |i|
    lead = {'LastName' => "#{params['name']}", 'Company' =>  "ABC #{i}"}
    id = create 'lead', lead.to_json
    output += "Created lead <a href='/lead/#{id}.json'>Lead ID=#{id}</a><br />"
  end

  output += '<tt></body></html>'
end

get '/lead/edit/:lead_id' do |lead_id|
  output = '<html><body><tt>'
   if (params.has_key? 'name' && params['name'] )
     lead = {'LastName' => params['name']}
     output += update 'lead', lead_id, lead.to_json
     output += "Updated lead <a href='/lead/#{lead_id}.json'>Lead ID=#{lead_id}</a>"
  end
  output += '<tt></body></html>'
end

get '/lead/delete/:lead_id' do |lead_id|
  output = '<html><body><tt>'
  if (lead_id)
    output += "<p>Deleting #{lead_id}</p>"
    output += delete 'lead', lead_id
  else
    output += request.inspect
  end
  output += '<tt></body></html>'
end


