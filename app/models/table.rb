class Table < ActiveRecord::Base
  belongs_to :event
  has_many :seatings
  has_many :users, :through => :seatings
end
