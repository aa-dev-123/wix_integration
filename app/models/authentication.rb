class Authentication < ApplicationRecord
  has_one :shop, dependent: :destroy

end
