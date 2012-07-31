class Event < ActiveRecord::Base
  has_many :tables
  has_many :seatings, :through => :tables
  
  def planned?
    !tables.empty?
  end
  
  def partition(wants)
    wants.partition{|w| seatings.find_by_user_id(w.who.id).table == seatings.find_by_user_id(w.wantable.id).table }
  end
  
  def forget_seating
    tables.clear
  end
    
  def plan_seating(users, wants)
    h = Hash.new
    users.each_with_index{|u, i| h[u] = i % groupsize }
    satisfied, unsatisfied = wants.partition{|w| h[w.who] == h[w.wantable] }
    
    until unsatisfied.empty?
      best, max, improved = h, total_priority(satisfied), false

      unsatisfied.sort{|w1, w2| w1.priority <=> w2.priority }.each{|w|
        # 希望に従って入れ替える
        if h[w.who] != h[w.wantable]
          us1 = h.select{|u, table| table == h[w.who] && u != w.who }.map{|u, _| u }
          us2 = h.select{|u, table| table == h[w.wantable] && u != w.wantable }.map{|u, _| u }
          
          if wantedscore(w.who, us1) > wantedscore(w.wantable, us2) # 元の部屋にそのままいる方が良い方を残す
            swap(h, w.wantable, us1.min{|u| wantedscore(u, us1) })
          else
            swap(h, w.who, us2.min{|u| wantedscore(u, us2) })
          end
        end
        
        # 入れ替え結果を評価する
        score = total_priority(wants.select{|w| h[w.who] == h[w.wantable] })
        best, max, improved = h.clone, score, true if score > max
      }

      satisfied, unsatisfied = wants.partition{|w| best[w.who] == best[w.wantable] }
      h = best
      break unless improved # 改善が見られなかったら、全ての希望を満たしていなくても探索終了
    end

    best.group_by{|user, table| table }.each{|t, us|
      tables.create(users: us.map{|u, t| u})
    }

  end
  
  
  protected
      
  def total_priority(wants)
    wants.inject(0){|sum, w| sum + w.priority }
  end
  
  def wantedscore(user, users)
    users.inject(0){|result, u| result + pair_priority(u, user) }
  end
  
  def pair_priority(u1, u2)
    wants = Want.where(who_id: u1.id, wantable_id: u2.id) + Want.where(who_id: u2.id, wantable_id: u1.id)
    total_priority(wants)
    # might better cache the score
  end

  def swap(h, u1, u2)
#    require "kconv"
#    puts "#{u1.name.tosjis} <=> #{u2.name.tosjis}"
    temp = h[u1]
    h[u1] = h[u2]
    h[u2] = temp
  end

end
