class OrderLineItem < ApplicationRecord
  belongs_to :order
  belongs_to :project
end
