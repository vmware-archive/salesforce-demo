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
  output = '<html><body><tt>'
  if (params.has_key? 'name' && params['name'] )
    name = params['name']
    n = 1
    n = params['n'].to_i if params['n']
    n.times do |i|
      opp = {
          'Name' => "#{i*100} #{name} Enterprise Licenses",
          'CloseDate' => "2012-#{(i % 12).to_s}-15",
          'StageName' => 'Negotiation/Review'
      }
      id = create 'opportunity', opp.to_json
      output += "Created opportunity <a href='/opportunity/#{id}.json'>Opportunity ID=#{id}</a><br />"
    end
  end
  output += '<tt></body></html>'
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


