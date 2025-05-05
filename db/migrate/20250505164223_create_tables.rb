class CreateTables < ActiveRecord::Migration[8.0]
  def change
    create_table :orders, id: :uuid do |t|
      t.string :external_id, null: false, index: {unique: true}
      t.datetie :placed_at
      t.datetime :locked_at
      t.timestamps
    end

    create_table :line_items, id: :uuid do |t|
      t.reference :order, null: false, foreigh_key: true
      t.string :sku, null: false
      t.integer :quantity, null: false
      t.boolean :original, default: true
      t.timestamps
    end

    create_table :sku_stats, id: :uuid do |t|
      t.string :sku, null: false
      t.string :week,
      t.integer :total_quantity, null: false
      t.timestamps
    end
  end
end
