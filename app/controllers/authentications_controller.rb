class AuthenticationsController < ApplicationController
  def create
    process_wix_install
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
    # omniauth.credentials.token
  end

end