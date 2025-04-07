class OauthController < ApplicationController
  def wix_auth
    redirect_uri = CGI.escape(ENV['WIX_REDIRECT_URL'])
    scopes = CGI.escape('stores_read orders_read') # Adjust as needed

    auth_url = "https://www.wix.com/installer/install?token=xyz&redirect_uri=#{redirect_uri}&client_id=#{ENV['WIX_CLIENT_ID']}"
    auth_url = "https://www.wix.com/app-market/install/468192a5-ac59-4801-ae39-08fa7a87539f"

    redirect_to auth_url
  end

  def wix_callback
    if params[:token]
      url = "https://www.wix.com/installer/install?token=#{params[:token]}&appId=#{ENV['WIX_CLIENT_ID']}&redirectUrl=#{ENV['WIX_REDIRECT_URL']}"

      redirect_to url
    end
  end

  def authorize
    if params[:code]
      authorization_code = params[:code]
      response = HTTParty.post("https://www.wix.com/oauth/access",
        body: {
          grant_type: 'authorization_code',
          client_id: ENV['WIX_CLIENT_ID'],
          client_secret: ENV['WIX_CLIENT_SECRET'],
          code: authorization_code
        }.to_json,
        headers: { 'Content-Type' => 'application/json' } 
      )

      tokens = JSON.parse(response.body)

      if tokens['access_token']
        # Store the tokens securely in the database later
        session[:wix_access_token] = tokens['access_token']
        session[:wix_refresh_token] = tokens['refresh_token']

        redirect_to root_path, notice: "Successfully connected to Wix!"
      else
        redirect_to root_path, notice: "Not successful"
      end
    end
  end
end
