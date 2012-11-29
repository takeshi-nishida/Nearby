class User < ActiveRecord::Base
  attr_accessible :name, :affiliation, :furigana, :password, :password_confirmation
  has_secure_password
  validates :password, presence: true, on: :create
  
  scope :excluded, where(exclude: true)
  scope :included, where(exclude: false)
  
  has_many :wants
  has_many :wanted, as: :wantable

  has_many :seatings
  has_many :tables, :through => :seatings
  
  has_many :topics
  
  def self.for_select
    all.map{|u| [u.name, u.id]  }.group_by { |u| u[0].length }
  end
  
  def self.grouped_options_by_affiliation
    g = all.group_by{|u| u.affiliation }
    g.each{|k, us| g[k] = us.map{|u| [u.name, u.id]} } 
  end
  
  def self.grouped_options_by_furigana
    g = all.group_by{|u| u.furigana[0] }
    g.each{|k, us| g[k] = us.map{|u| [u.name, u.id]} }
  end
 
  def name_with_affiliation
    "#{name} (#{affiliation})"
  end
  
  def topics
    wants.select{|w| w.wantable_type == "Topic" }.map{|w| w.wantable }
  end
  
  # 重いので注意
  def satisfied?
    wants.any?{|w| w.satisfied? }
  end
end
