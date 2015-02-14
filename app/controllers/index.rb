CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

use Rack::Session::Pool, :cookie_only => false

get '/' do
  api = Github::Client.new
  if !authenticated?
    authenticate!
  else
    access_token = session[:access_token]
    scopes = []

    begin
      auth_result = RestClient.get('https://api.github.com/user',
                                   {:params => {:access_token => access_token},
                                    :accept => :json})
      p auth_result
    rescue => e

      session[:access_token] = nil
      return authenticate!
    end

    # the request succeeded, so we check the list of current scopes
    if auth_result.headers.include? :x_oauth_scopes
      scopes = auth_result.headers[:x_oauth_scopes].split(', ')
    end

    auth_result = JSON.parse(auth_result)
    if scopes.include? 'user:email'
      auth_result['private_emails'] =
        JSON.parse(RestClient.get('https://api.github.com/user/emails',
                       {:params => {:access_token => access_token},
                        :accept => :json}))
    end
    if scopes.include? 'read:org'
      auth_result['orgs'] =
        JSON.parse(RestClient.get('https://api.github.com/user/orgs',
                 {:params => {:access_token => access_token},
                  :accept => :json}))
    end
    erb :advanced, :locals => auth_result
  end
end

get '/callback' do
  session_code = request.env['rack.request.query_hash']['code']

  result = RestClient.post('https://github.com/login/oauth/access_token',
                          {:client_id => CLIENT_ID,
                           :client_secret => CLIENT_SECRET,
                           :code => session_code},
                           :accept => :json)

  session[:access_token] = JSON.parse(result)['access_token']

  redirect '/'
end

get '/users/:org' do
  org = params[:org]
  api = Github::Client.new
  access_token = session[:access_token]
  response = api.posts("orgs/#{org}/members?access_token=#{access_token}")
  @avatar_array = []
  response.each do |e|
    @avatar_array << e["avatar_url"]
  end
  erb :org
end
