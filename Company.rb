COMPANY_FIELDS = ['id', 'name', 'description', 'founded-year', 'universal-name', 'locations', 'email-domains', 'company-type', 'website-url', 'ticker', 'logo-url', 'twitter-id', 'employee-count_range']

get '/companies' do
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
    session[:recent_companies] = {} unless session[:recent_companies]
    session[:recent_companies][company_id] = @company.to_json
    puts "Session  #{session[:recent_companies].inspect}"
  rescue OAuth2::Error => e
     return e.response.inspect
  end
  haml :company
end

get '/company/raw/:company_id.json' do |company_id|
  # TODO
end

get  '/company/add/:company_id.json' do |company_id|
      puts "Session**** #{session[:recent_companies].inspect}"
  if session[:recent_companies] && session[:recent_companies][company_id]
    session[:companies_in_cart] = {} unless session[:companies_in_cart]
    session[:companies_in_cart][company_id] = session[:recent_companies][company_id]
    output = "Added #{company_id}"
  end
end

