class Shop < ApplicationRecord
  belongs_to :authentication

  def is_token_active?
    self.authentication.token_expires_at.future?
  end
end
