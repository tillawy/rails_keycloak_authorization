class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations, id: :uuid  do |t|
      t.text :name

      t.timestamps
    end
  end
end
