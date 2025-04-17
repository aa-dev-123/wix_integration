class Authentication < ApplicationRecord
  has_one :shop, dependent: :destroy

  validates :uid, uniqueness: true
end
