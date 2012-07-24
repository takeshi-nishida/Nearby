class CreateWants < ActiveRecord::Migration
  def change
    create_table :wants do |t|
      t.references :user
      t.references :who
      t.references :wantable, polymorphic: true

      t.timestamps
    end
    add_index :wants, :user_id
    add_index :wants, :who_id
    add_index :wants, :wantable_id
  end
end
