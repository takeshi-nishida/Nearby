class User < ActiveRecord::Base
  attr_accessible :name, :email, :affiliation, :furigana, :category, :sex, :password, :password_confirmation, :insecure_password
  has_secure_password
  validates :password, presence: true, on: :create
  
  scope :excluded, where(exclude: true)
  scope :included, where(exclude: false)
  
  has_many :wants, :dependent => :destroy
  has_many :wanted, as: :wantable

  has_many :seatings
  has_many :tables, :through => :seatings
  
  has_many :topics
  
  def self.for_select
    all.map{|u| [u.name, u.id]  }.group_by { |u| u[0].length }
  end
  
  def self.grouped_options_by_affiliation
    g = all.group_by{|u| u.affiliation }
    g.each{|k, us| g[k] = us.map{|u| [u.name, u.id, "data-category" => u.category ] } } 
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
  
  def popularity
    Want.where(wantable_type: "User", wantable_id: self.id).count
  end
  
  # 重いので注意
  def satisfied?
    wants.any?{|w| w.satisfied? }
  end
  
  def impossible?
    wants.all?{|w| w.impossible? }
  end
end
