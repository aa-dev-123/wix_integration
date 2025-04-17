class Shop < ApplicationRecord
  belongs_to :authentication
  validates :external_shop_id, uniqueness: true

  def is_token_active?
    self.authentication.token_expires_at.future?
  end
end
