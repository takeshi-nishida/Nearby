class Want < ActiveRecord::Base
  belongs_to :user
  belongs_to :who, class_name: "User"
  belongs_to :wantable, polymorphic: true
  
  validates_associated :user, :who, :wantable
#  validates :wantable, :uniqueness => { :scope =>  [:user, :who], :message => "no duplication." }
  validate :cannot_want_yourself
  
  private
  def cannot_want_yourself
    errors.add(:wantable, "Two persons cannot be the same.") if who == wantable
  end
end
