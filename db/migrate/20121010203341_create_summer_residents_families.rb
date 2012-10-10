class CreateSummerResidentsFamilies < ActiveRecord::Migration
  def change
    create_table :summer_residents_families do |t|
      t.integer :home_id
      t.integer :bungalow_id
      t.integer :father_id
      t.integer :mother_id

      t.timestamps
    end
  end
end
