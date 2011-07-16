class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
      t.string :transaction_id
      t.string :cvv2_code
      t.string :avs_code
      t.decimal :amount
      t.string :token

      t.timestamps
    end
  end

  def self.down
    drop_table :purchases
  end
end
