class Table < ActiveRecord::Base
  belongs_to :event
  has_many :seatings, :dependent => :delete_all
  has_many :users, :through => :seatings
  
  def popular_topics
    h = Hash.new(0)
    users.flat_map{|u| u.topics }.each{|topic| h[topic] += 1 }
    h.sort{|a, b| b[1] <=> a[1] }.select{|a| a[1] > 1}.map{|a| a[0] }
  end  
end
