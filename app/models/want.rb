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
  
  # どちらかが「自分で自分の席を決めたい」を希望している場合は、残念ながらその希望はかなえられない
  def exclude?
    who.exclude or (wantable_type == "User" and wantable.exclude)
  end
  
  # 結構重いので注意
  def satisfied?
    tables = Event.all.map{|e| e.tables }.flatten
    case wantable_type
    when "User"
      tables.any?{|table| (table.users & [who, wantable]).size == 2 }
    when "Topic"
      tables.any?{|table| table.popular_topics.include?(wantable) }
    end
  end
  
  # [uid1, uid2] => priority for the two というハッシュを作成
  def self.priorities
    h = Hash.new(0)

    # 1. 人希望を追加する
    for_user.reject{|w| w.exclude? }.each{|w|
      key = [w.who.id, w.wantable.id].sort;
      h[key] = w.priority if w.priority > h[key]
    }

    # 2. 話題希望を追加する
    Topic.find_each{|topic|
      topic.wants.reject{|w| w.exclude? }.map{|w| w.who.id }.combination(2).each{|a| h[a.sort] = 1 }
    }
    
    # 3. 既にかなっている希望を減点する
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
