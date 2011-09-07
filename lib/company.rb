COMPANY_FIELDS = ['id', 'name', 'description', 'founded-year', 'universal-name', 'locations', 'email-domains', 'company-type', 'website-url', 'ticker', 'logo-url', 'twitter-id', 'employee-count_range']

get '/companies' do
  @title = 'Companies'
  @controller = 'companies'
  @data = lnk_show_all_companies
  haml :show_all
end

def lnk_show_all_companies options={}
  lnk_client = get_linkedin_client
  begin
    response = lnk_client.company_search(params['q'])
    puts "RESPONSE #{response.inspect}"

    output = '<ul>'
    object_type = 'company'
    response.companies.all.each do |record|
      output += "<li>#{record.id}, #{record.name}, <a href='/#{object_type}/#{record.id}'>Show</a></li>"
    end
    output += '</ul>'

  rescue OAuth2::Error => e
      e.response.inspect
  end
end

get '/company/:company_id' do |company_id|
  lnk_client = get_linkedin_client
  @company = nil
  begin
    @company = lnk_client.company({:id => company_id, :fields => COMPANY_FIELDS})
    @@redis.set "company_#{company_id}", @company.to_json
    @title = @company.name
  rescue OAuth2::Error => e
     return e.response.inspect
  end
  haml :company
end

get '/company/raw/:company_id.json' do |company_id|
  # TODO
end

get  '/company/add/:company_id.json' do |company_id|
  if @@redis.get "company_#{company_id}"
    @@redis.sadd cart_id, "company_#{company_id}"
    redirect "/"
  end
end

