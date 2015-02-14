helpers do

  def authenticated?
    session[:access_token]
  end

  def authenticate!
    erb :index, :locals => {:client_id => CLIENT_ID}
  end
end
