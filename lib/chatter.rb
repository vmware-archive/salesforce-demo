get '/chatter_user/me' do
  @object_type = 'chatter_user'
  @item_id = 'me'
  @item_data = nil

  begin
    response = access_token.get("#{instance_url}/services/data/v22.0/chatter/users/me", :headers => {'Content-type' => 'application/json'})
    @item_data = response.parsed
    @item_data.delete 'currentStatus'
    @record_title = @item_data['name']

  rescue OAuth2::Error => e
     SalesforceDemo::Config.logger.error("Got error getting chatter current user #{e.response.inspect }")
  end

  haml :show_one
end

get '/chatter_user/raw/me.json' do
  response = access_token.get("#{instance_url}/services/data/v22.0/chatter/users/me", :headers => {'Content-type' => 'application/json'})
  response.body
end