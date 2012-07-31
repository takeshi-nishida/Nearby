class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables do |t|
      t.references :event

      t.timestamps
    end
    add_index :tables, :event_id
  end
end
