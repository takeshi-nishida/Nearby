class User < ActiveRecord::Base
  attr_accessible :name, :password, :password_confirmation
  has_secure_password
  validates :password, presence: true, on: :create
  
  has_many :wants
  has_many :wanted, as: :wantable

  has_many :seatings
  has_many :tables, :through => :seatings
end
