class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :description
      t.string :style
      t.integer :size1
      t.integer :number1
      t.integer :size2
      t.integer :number2

      t.timestamps
    end
  end
end
