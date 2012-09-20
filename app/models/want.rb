class Want < ActiveRecord::Base
  belongs_to :user
  belongs_to :who, class_name: "User"
  belongs_to :wantable, :polymorphic => true
  
  validates_associated :user, :who, :wantable
#  validates :wantable, :uniqueness => { :scope =>  [:user, :who], :message => "no duplication." }
  validate :cannot_want_yourself
  
  scope :for_user, where(wantable_type: "User")
  scope :for_topic, where(wantable_type: "Topic")
  
  def priority
    user == who || user == wantable ? 2 : 1 # 本人による希望を2倍優先する
  end
  
  def self.priorities
    h = Hash.new(0)
    for_user.each{|w|
      key = [w.who.id, w.wantable.id].sort;
      h[key] = w.priority if w.priority > h[key]
    }
    Topic.all.each{|topic|
      topic.wants.map{|w| w.who.id }.combination(2).each{|a| h[a.sort] = 2 }
    }
    tables = Event.all.flat_map{|e| e.tables }
    tables.each{|table|
      table.users.map{|u| u.id }.combination(2).each{|a|
        key = a.sort
        h[key] = -1 if h[key] > 0
     }
    }
    h
  end
  
  private
  def cannot_want_yourself
    errors.add(:wantable, "Two persons cannot be the same.") if who == wantable
  end
end
