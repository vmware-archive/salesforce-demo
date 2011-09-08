get '/chatter/me' do
  @object_type = 'chatter_user'
  @item_id = 'me'
  @item_data = nil

  begin
    response = access_token.get("#{INSTANCE_URL}/services/data/v22.0/chatter/users/me", :headers => {'Content-type' => 'application/json'})
    @item_data = response.parsed
    @title = @item_data['name']

  rescue OAuth2::Error => e
     puts "Got error getting chatter current user #{e.response.inspect }"
  end

  haml :show_one
end