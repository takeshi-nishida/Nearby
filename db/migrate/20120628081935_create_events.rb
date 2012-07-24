class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :description
      t.integer :groupsize

      t.timestamps
    end
  end
end
