class Project < ApplicationRecord
  validates :external_reference_id, uniqueness: true
end
