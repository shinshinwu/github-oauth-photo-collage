module Github

  class Client
    include HTTParty
    base_uri "https://api.github.com"

    def gets(endpoint, access_token)
      response = self.class.get("/#{endpoint}",
                                {:params => {:access_token => access_token},
                                    :accept => :json}, headers: {"User-Agent" => "shinshinwu"})
      return JSON.parse(response.body)
    end

    def posts(endpoint)
      response = self.class.get("/#{endpoint}", headers: {"User-Agent" => "shinshinwu"})

      return JSON.parse(response.body)
    end

    # def authenticated?
    #   session[:access_token]
    # end

    # def authenticate!
    #   erb :index, :locals => {:client_id => CLIENT_ID}
    # end

  end

end
