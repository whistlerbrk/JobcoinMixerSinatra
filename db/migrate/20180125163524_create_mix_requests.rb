class CreateMixRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :mix_requests do |t|
      t.string :deposit_address, null: false
      t.string :distribution_addresses, null: false
      t.integer :status, default: 0, null: false
      t.string :deposit_amount

      t.timestamps
    end
  end
end
