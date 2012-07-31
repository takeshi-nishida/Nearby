class CreateSeatings < ActiveRecord::Migration
  def change
    create_table :seatings do |t|
      t.references :user
      t.references :table

      t.timestamps
    end
    add_index :seatings, :user_id
    add_index :seatings, :table_id
  end
end
