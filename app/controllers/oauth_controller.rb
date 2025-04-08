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
      tokens = WixService.new.exchange_code_for_token(authorization_code)

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
