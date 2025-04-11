class OauthController < ApplicationController
  def wix_auth
    redirect_to WixService.new.auth_url
  end

  def wix_callback
    if params[:token]
      redirect_to WixService.new.install_url(params[:token])
    end
  end

  def authorize
    if params[:code]
      authorization_code = params[:code]
      successful = WixService.new.exchange_code_for_token(authorization_code)

      if successful
        redirect_to root_path, notice: "Successfully connected to Wix!"
      else
        redirect_to root_path, notice: "Not successful"
      end
    end
  end
end
