class WixService
  include HTTParty
  require 'ostruct'

  BASE_URI = 'https://www.wix.com'
  BASE_REST_URI = 'https://www.wixapis.com'

  def initialize(shop = nil)
    @shop = shop
  end

  def auth_url
    "#{BASE_URI}/app-market/install/468192a5-ac59-4801-ae39-08fa7a87539f"
  end

  # Generate installation URL after Wix returns a token
  def install_url(token)
    "#{BASE_URI}/installer/install?token=#{token}&appId=#{ENV['WIX_CLIENT_ID']}&redirectUrl=#{ENV['WIX_REDIRECT_URL']}"
  end

  def exchange_code_for_token(authorization_code)
    response = self.class.post("#{BASE_URI}/oauth/access",
      body: token_request_body(authorization_code).to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    return unless response.success?

    tokens = JSON.parse(response.body)

    create_shop_and_authentication(tokens)
  end

  def refresh_token
    response = self.class.post("#{BASE_URI}/oauth/access",
      body: refresh_token_body.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    return unless response.success?

    tokens = JSON.parse(response.body)
    @shop.authentication.update(token: tokens["access_token"], refresh_token: tokens["refresh_token"], token_expires_at: 5.minutes.from_now)
  end

  def get_products
    refresh_token unless @shop.is_token_active?

    response = self.class.post("#{BASE_REST_URI}/stores/v1/products/query",
      headers: auth_headers,
      body: { includeVariants: true }.to_json
    )

    return unless response.success?

    response["products"].each do |wix_product|
      create_project(wix_product)
    end
  end

  def get_orders
    refresh_token unless @shop.is_token_active?

    response = self.class.post("#{BASE_REST_URI}/stores/v2/orders/query",
      headers: auth_headers
    )

    return unless response.success?

    response["orders"].each do |wix_order|
      create_order(wix_order)
    end
  end

  private

  def token_request_body(authorization_code)
    {
      grant_type: 'authorization_code',
      client_id: ENV['WIX_CLIENT_ID'],
      client_secret: ENV['WIX_CLIENT_SECRET'],
      code: authorization_code
    }
  end

  def refresh_token_body
    {
      grant_type: 'refresh_token',
      client_id: ENV['WIX_CLIENT_ID'],
      client_secret: ENV['WIX_CLIENT_SECRET'],
      refresh_token: @shop.authentication.refresh_token
    }
  end

  def create_authentication(tokens, uid)
    authentication = Authentication.where(uid: uid).first_or_initialize

    if authentication.new_record?
      authentication.update(token: tokens['access_token'], refresh_token: tokens['refresh_token'], token_expires_at: 5.minutes.from_now)
    end

    authentication
  end

  def create_shop_and_authentication(tokens)
    site_info = fetch_site_info(tokens['access_token'])
    return unless site_info

    authentication = create_authentication(tokens, site_info["instance"]["instanceId"])

    @shop = Shop.where(external_shop_id: site_info["site"]["siteId"]).first_or_initialize

    if @shop.new_record?
      @shop.update(description: site_info["site"]["description"], name: site_info["site"]["siteDisplayName"], url: site_info["site"]["url"], authentication_id: authentication.id)
    end
  end

  def fetch_site_info(authorization_code = nil)
    response = HTTParty.get("#{BASE_REST_URI}/apps/v1/instance", headers: auth_headers(authorization_code))
    response.success? ? JSON.parse(response.body) : nil
  end

  def auth_headers(authorization_code = nil)
    { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{@shop&.authentication&.token || authorization_code}" }
  end

  def create_project(wix_product)
    wix_product = OpenStruct.new(wix_product)

    project = Project.where(external_reference_id: wix_product.id).first_or_initialize

    if project.new_record?
      project.update(
        name: wix_product.name,
        sku: wix_product.sku ? wix_product.sku : nil,
        product_type: wix_product.productType,
        description: wix_product.description,
        price: wix_product.price["price"],
        currency: wix_product.price["currency"]
      )
    end
  end

  def create_order(wix_order)
    wix_order = OpenStruct.new(wix_order)
    order = Order.create(
      external_reference_id: wix_order.id,
      subtotal: wix_order.subtotal,
      shipping: wix_order.totals["shopping"],
      tax: wix_order.totals["tax"],
      discount: wix_order.totals["discount"],
      total: wix_order.totals["total"]
    )

    wix_order.lineItems.each do |line_item|
      line_item = OpenStruct.new(line_item)
      project = Project.find_by(external_reference_id: line_item.productId)
      order.order_line_items.create(
        project_id: project.id,
        quantity: line_item.quantity,
        price: line_item.price,
        total_price: line_item.totalPrice,
        discount: line_item.discount,
        tax: line_item.tax
      )
    end
  end
end