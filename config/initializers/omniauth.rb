Rails.application.config.middleware.use OmniAuth::Builder do
  provider :wix, ENV['WIX_CLIENT_ID'], ENV['WIX_CLIENT_SECRET']
end
