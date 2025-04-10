class WixService
  include HTTParty
  attr_accessor :base_uri, :base_rest_uri

  def initialize
    @base_uri = 'https://www.wix.com'
    @base_rest_uri = 'https://www.wixapis.com'
  end

  def auth_url
    "#{@base_uri}/app-market/install/468192a5-ac59-4801-ae39-08fa7a87539f"
  end

  # Generate installation URL after Wix returns a token
  def install_url(token)
    "#{@base_uri}/installer/install?token=#{token}&appId=#{ENV['WIX_CLIENT_ID']}&redirectUrl=#{ENV['WIX_REDIRECT_URL']}"
  end

  def exchange_code_for_token(authorization_code)
    response = self.class.post("#{@base_uri}/oauth/access",
      body: {
        grant_type: 'authorization_code',
        client_id: ENV['WIX_CLIENT_ID'],
        client_secret: ENV['WIX_CLIENT_SECRET'],
        code: authorization_code
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    if response.success?
      tokens = JSON.parse(response.body)

      url = "#{base_rest_uri}/apps/v1/instance"

      response = HTTParty.get(url, headers: { "Authorization" => "Bearer #{tokens['access_token']}" })

      response = JSON.parse(response.body)

      authentication = Authentication.where(uid: response["instance"]["instanceId"]).first_or_initialize

      authentication.update(token: tokens['access_token'], refresh_token: tokens['refresh_token'], token_expires_at: 5.minutes.from_now)
      
      shop = Shop.where(authentication_id: authentication.id, name: response["site"]["siteDisplayName"]).first_or_initialize

      shop.save
    end
  end

  def refresh_token(authentication)
    response = self.class.post("#{@base_uri}/oauth/access",
      body: {
        grant_type: 'refresh_token',
        client_id: ENV['WIX_CLIENT_ID'],
        client_secret: ENV['WIX_CLIENT_SECRET'],
        code: authorization_code
        refresh_token: authentication.refresh_token
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    tokens = JSON.parse(response.body)

    authentication.update(token: tokens["access_token"], refresh_token: tokens["refresh_token"], token_expires_at: 5.minutes.from_now)
  end
end