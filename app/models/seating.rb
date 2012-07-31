class Seating < ActiveRecord::Base
  belongs_to :user
  belongs_to :table
  delegate :event, :to => :table, :allow_nil => false
end
