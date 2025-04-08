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

    JSON.parse(response.body)
  end
end