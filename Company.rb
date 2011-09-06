get '/companies' do
  @controller = 'companies'
  @data = lnk_show_all_companies
  haml :show_all
end

get '/company/:company_id' do |company_id|
  output = "<html><body><a href='/company/raw/#{company_id}.json'>JSON</a><br /><tt>"
  output += lnk_show_company company_id
  output += '<tt></body></html>'
end

get '/company/raw/:company_id.json' do |company_id|
  response = lnk_show_company company_id, {:raw => true}
  response
end