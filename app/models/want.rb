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
    # 本人による希望を優先する。１つも希望がかなっていない人の希望を優先する。
    user == who || user == wantable ? (user.satisfied? ? 4 : 6) : 1
#      user == who || user == wantable ? 2 : 1
  end
  
# どちらかが「自分で自分の席を決めたい」を希望している場合は、残念ながらその希望はかなえられない
#  def exclude?
#    who.exclude or (wantable_type == "User" and wantable.exclude)
#  end
  
  # 結構重いので注意
  def satisfied?
#    tables = Event.all.map{|e| e.tables }.flatten
    case wantable_type
    when "User"
      # who が属するテーブルに wantable が存在
      who.tables.any?{|table| table.users.include?(wantable) }
#      tables.any?{|table| (table.users & [who, wantable]).size == 2 }
    when "Topic"
      # user が続するテーブルに wantable を希望している人が存在する
      who.tables.any?{|table|
        table.users.any?{|u| user != u and u.topics.include?(wantable) }
      }
#      tables.any?{|table| table.popular_topics.include?(wantable) }
    end
  end
  
  # 絶対に叶えられない希望かどうか
  def impossible?
    case wantable_type
    when "User"
      who.exclude or wantable.exclude
    when "Topic"
      who.exclude or wantable.wants.size < 2
    end
  end
  
  # [uid1, uid2] => priority というハッシュを3つ作成（人希望, 話題希望, 減点)
  # 注意: uid1 と uid2 はソートされているので、引くときもソートすること
  def self.priorities
    # 1. 人希望
    h1 = Hash.new(0)
    for_user.reject{|w| w.impossible? }.each{|w|
      key = [w.who.id, w.wantable.id].sort;
      p = w.priority
      h1[key] = p if p > h1[key]
    }

    # 2. 話題希望 (同じ話題を希望している２人は本人希望と同評価)
    h2 = Hash.new(0)
    Topic.find_each{|topic|
      topic.wants.reject{|w| w.impossible? }.map{|w| w.who.id }.combination(2).each{|a| h2[a.sort] = 2 }
    }
    
    # 3. 既に同じテーブルになったことがある人は(希望に関わらず)減点する。h1,h2からも除外する。
    h3 = Hash.new(0)
    tables = Event.all.flat_map{|e| e.tables }
    tables.each{|table|
      table.users.reject{|u| u.exclude }.map{|u| u.id }.combination(2).each{|a|
        key = a.sort
        h1.delete(key)
        h2.delete(key)
        h3[key] = -100
     }
    }
    
    return h1, h2, h3
  end
  
  private
  def cannot_want_yourself
    errors.add(:wantable) if wantable == nil
    errors.add(:wantable, "Two persons cannot be the same.") if who == wantable
  end
end
