class AddExternalReferenceIdToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :external_reference_id, :string
  end
end
