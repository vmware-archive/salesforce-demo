get '/companies' do
  @controller = 'companies'
  @data = lnk_show_all 'company'
  haml :show_all
end

