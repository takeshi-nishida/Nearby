class AddDetailsToUser < ActiveRecord::Migration
  def change
    add_column :users, :affiliation, :string
    add_column :users, :type, :string
    add_column :users, :furigana, :string
  end
end
