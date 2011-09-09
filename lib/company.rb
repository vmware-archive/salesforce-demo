COMPANY_FIELDS = ['id', 'name', 'description', 'founded-year', 'universal-name', 'locations', 'email-domains', 'website-url', 'ticker', 'logo-url', 'twitter-id', 'employee-count_range']

get '/companies' do
  @record_title = 'Companies'
  @controller = 'companies'
  lnk_client = get_linkedin_client
  @data = nil
  begin
    @data = lnk_client.company_search(params['q']).companies.all
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
    @@redis.set "company_#{company_id}", @company.to_json
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
  if @@redis.get "company_#{company_id}"
    @@redis.sadd cart_id, "company_#{company_id}"
    redirect "/companies"
  end
end

