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
    seatings.clear
  end
    
  def plan_seating(users, priorities)
    h = Hash.new
    users.shuffle.each_with_index{|u, i| h[u.id] = i % groupsize }

    pairs = priorities.sort{|a, b| b[1] <=> a[1] }.map{|pair, score| pair }
    satisfied, unsatisfied = pairs.partition{|pair| sametable(h, pair[0], pair[1]) }
    
    until unsatisfied.empty?
      best, max, improved = h, total_priority(satisfied, priorities), false

      unsatisfied.each{|pair|
        # 希望に従って入れ替える
        u1, u2 = pair[0], pair[1]
        if not sametable(h, u1, u2)
          users1 = h.select{|u, table| table == h[u1] && u != u1 }.map{|u, _| u } # u1 と同じテーブルの人々
          users2 = h.select{|u, table| table == h[u2] && u != u2 }.map{|u, _| u } # u2 と同じテーブルの人々
          
          if wantedscore(u1, users1, priorities) > wantedscore(u2, users2, priorities) # 元の部屋にそのままいる方が良い方を残す
            swap(h, u2, users1.min{|u| wantedscore(u, users1, priorities) })
          else
            swap(h, u1, users2.min{|u| wantedscore(u, users2, priorities) })
          end
        end
        
        # 入れ替え結果を評価する
        score = total_priority(pairs.select{|pair| sametable(h, pair[0], pair[1])}, priorities)
        best, max, improved = h.clone, score, true if score > max
      }

      satisfied, unsatisfied = pairs.partition{|pair| sametable(best, pair[0], pair[1]) }
      h = best
      break unless improved # 改善が見られなかったら、全ての希望を満たしていなくても探索終了
    end

    best.group_by{|user, table| table }.each{|t, us|
      tables.create(:user_ids => us.map{|u, t| u} )
    }

  end
  
  
  protected
  
  def sametable(h, u1, u2)
    h[u1] == h[u2]
  end
      
  def total_priority(pairs, priorities)
    pairs.inject(0){|sum, pair| sum + priorities[pair] }
  end
  
  def wantedscore(user, users, priorities)
    users.inject(0){|result, u| result + priorities[[u, user].sort] }
  end
  
#  def pair_priority(u1, u2)
#    wants = Want.where(who_id: u1.id, wantable_id: u2.id) + Want.where(who_id: u2.id, wantable_id: u1.id)
#    total_priority(wants)
#    # might better cache the score
#  end

  def swap(h, u1, u2)
    temp = h[u1]
    h[u1] = h[u2]
    h[u2] = temp
  end

end
