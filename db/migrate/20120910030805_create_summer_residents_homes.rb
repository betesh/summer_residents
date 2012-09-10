class CreateSummerResidentsHomes < ActiveRecord::Migration
  def change
    create_table :summer_residents_homes do |t|
      t.string :address
      t.string :apartment
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.integer :phone

      t.timestamps
    end
  end
end
