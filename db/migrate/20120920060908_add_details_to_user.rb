class AddDetailsToUser < ActiveRecord::Migration
  def change
    add_column :users, :affiliation, :string
    add_column :users, :category, :string
    add_column :users, :furigana, :string
    add_column :users, :sex, :integer
    
  end
end
