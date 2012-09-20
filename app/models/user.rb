class User < ActiveRecord::Base
  attr_accessible :name, :password, :password_confirmation
  has_secure_password
  validates :password, presence: true, on: :create
  
  has_many :wants
  has_many :wanted, as: :wantable

  has_many :seatings
  has_many :tables, :through => :seatings
  
  def self.for_select
    all.map{|u| [u.name, u.id]  }.group_by { |u| u[0].length }
  end
  
  def topics
    wants.select{|w| w.wantable_type == "Topic" }.map{|w| w.wantable }
  end
end
