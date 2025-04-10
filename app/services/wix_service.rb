class WixService
  include HTTParty
  require 'ostruct'

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
        code: Authentication.first.token,
        refresh_token: authentication.refresh_token
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    tokens = JSON.parse(response.body)

    authentication.update(token: tokens["access_token"], refresh_token: tokens["refresh_token"], token_expires_at: 5.minutes.from_now)
  end

  def get_products
    refresh_token(Authentication.first) unless Shop.first.is_token_active?
    
    response = self.class.post(
      "#{@base_rest_uri}/stores/v1/products/query",
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{Authentication.first.token}"
      },
      body: { includeVariants: true }.to_json
    )

    response = JSON.parse(response.body)

    response["products"].map do |wix_product|
      wix_product = OpenStruct.new(wix_product)
      Project.create(external_reference_id: wix_product.id, name: wix_product.name, sku: '', product_type: wix_product.productType, description: wix_product.description, price: wix_product.price["price"], currency: wix_product.price["currency"])
    end
  end

  def get_orders
    refresh_token(Authentication.first) unless Shop.first.is_token_active?
    
    response = self.class.post(
      "#{@base_rest_uri}/stores/v2/orders/query",
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{Authentication.first.token}"
      }
    )

    response = JSON.parse(response.body)

    response["orders"].map do |wix_order|
      wix_order = OpenStruct.new(wix_order)
      Order.create(external_reference_id: wix_order.id, subtotal: wix_order.subtotal, shipping: wix_order.totals["shopping"], tax: wix_order.totals["tax"], discount: wix_order.totals["discount"], total: wix_order.totals["total"])

      wix_order.lineItems.each do |line_item|
        
      end      
    end
  end
end