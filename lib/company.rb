COMPANY_FIELDS = ['id', 'name', 'description', 'industry', 'blog-rss-url', 'founded-year', 'universal-name', 'locations', 'email-domains', 'website-url', 'ticker', 'logo-url', 'twitter-id', 'employee-count_range']

post '/cart/empty' do
 SalesforceDemo::Config.redis.del cart_id

 redirect '/'
end


get '/companies' do
  @record_title = 'Companies'
  @controller = 'companies'
  lnk_client = get_linkedin_client
  @data = nil
  SalesforceDemo::Config.redis.set(search_id, params['q']) if params['q']
  @search_term = SalesforceDemo::Config.redis.get(search_id)
  begin
    @data = lnk_client.company_search(@search_term).companies.all
    @object_type = 'company'
  rescue OAuth2::Error => e
    e.response.inspect
  end
  haml :show_all
end

get '/company/:company_id' do |company_id|
  lnk_client = get_linkedin_client
  @company = nil
  begin
    @company = lnk_client.company({:id => company_id, :fields => COMPANY_FIELDS})
    SalesforceDemo::Config.redis.set "company_#{company_id}", @company.to_json
    @company.delete 'email-domains'
    if (@company['twitter_id'] && @company['twitter_id'] =~ /^[a-zA-Z_]+$/)
      @company['twitter_id'] = "http://twitter.com/" + @company['twitter_id']
    end
    @record_title = @company['name']
  rescue OAuth2::Error => e
    return e.response.inspect
  end
  haml :company
end

get '/company/raw/:company_id.json' do |company_id|
  # TODO
end

get  '/company/add/:company_id.json' do |company_id|
  if SalesforceDemo::Config.redis.get "company_#{company_id}"
    SalesforceDemo::Config.redis.sadd cart_id, "company_#{company_id}"
    redirect "/companies?q=#{@search_term}"
  end
end

