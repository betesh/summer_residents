class ChangePhoneToDecimal < ActiveRecord::Migration
  def up
    change_column :summer_residents_residents, :cell, :decimal, :precision => 10, :scale => 0
    change_column :summer_residents_bungalows, :phone, :decimal, :precision => 10, :scale => 0
    change_column :summer_residents_homes, :phone, :decimal, :precision => 10, :scale => 0
  end

  def down
    change_column :summer_residents_residents, :cell, :integer
    change_column :summer_residents_bungalows, :phone, :integer
    change_column :summer_residents_homes, :phone, :integer
  end
end
