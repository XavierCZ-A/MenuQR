class AddAddressAndHoursToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :address, :string
    add_column :restaurants, :hours, :string
  end
end
