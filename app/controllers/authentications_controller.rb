class AuthenticationsController < ApplicationController
  def create
    process_wix_install

    redirect_to shops_path, notice: "Shop was successfully created."
  end

  def blank
    # Wix can be installed via the Wix App Market which redirects here via GET, so we need to catch it and redirect via POST
    repost("/auth/wix", params: { provider: "wix", token: params[:token] }, options: { authenticity_token: :auto }) and return
  end

  private

  def omniauth
    request.env["omniauth.auth"]
  end

  def process_wix_install
    auth = omniauth

    wix_instance_id = auth.uid
    access_token = auth.credentials.token
    email = auth.info.email
    site_url = auth.info.site_url

    # Store or update the Wix shop/app installation in your DB
    authentication = Authentication.find_or_initialize_by(uid: wix_instance_id)

    if authentication.new_record?
      authentication.update!(
        token: auth.credentials.token,
        refresh_token: auth.credentials.refresh_token
      )

      shop = Shop.where(external_shop_id: auth.extra.raw_info.site_id).first_or_initialize

      if shop.new_record?
        shop.update(name: auth.extra.raw_info.site_display_name, url: auth.extra.raw_info.url, authentication_id: authentication.id)
      end
    end
  end
end