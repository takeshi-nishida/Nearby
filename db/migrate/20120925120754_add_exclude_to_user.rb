class AddExcludeToUser < ActiveRecord::Migration
  def change
    add_column :users, :exclude, :boolean, default: false

  end
end
