get '/opportunities' do
  @controller = 'opportunities'
  @data = show_all 'opportunity'
  @title = "Opportunities"
  haml :show_all
end

get '/opportunities.json' do
  response = show_all 'opportunity', {:raw => true}
  response
end

get '/opportunity/:opportunity_id' do |opportunity_id|
  output = "<html><body><a href='/opportunity/raw/#{opportunity_id}.json'>JSON</a><br /><tt>"
  output += show_one 'opportunity', opportunity_id
  output += '<tt></body></html>'
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
      opp = {'Name' => "#{i*100} #{name} Enterprise Licenses", 'CloseDate' => "2012-#{(i % 12).to_s}-15", 'StageName' => 'Negotiation/Review'}
      id = create 'opportunity', opp.to_json
      output += "Created opportunity <a href='/opportunity/#{id}.json'>Opportunity ID=#{id}</a><br />"
    end
  end
  output += '<tt></body></html>'
end

get '/opportunity/edit/:opportunity_id' do |opportunity_id|
  output = '<html><body><tt>'
   if (params.has_key? 'name' && params['name'] )
     opp = {'Name' => params['name']}
     output += update 'opportunity', opportunity_id, opp.to_json
     output += "Updated opportunity <a href='/opportunity/#{opportunity_id}.json'>Opportunity ID=#{opportunity_id}</a>"
  end
  output += '<tt></body></html>'
end

get '/opportunity/delete/:opportunity_id' do |opportunity_id|
  output = '<html><body><tt>'
  if (opportunity_id)
    output += "<p>Deleting #{opportunity_id}</p>"
    output += delete 'opportunity', opportunity_id
    redirect '/opportunities'
  else
    output += request.inspect
  end
  output += '<tt></body></html>'
end


