class Event < ActiveRecord::Base
  validate :has_enough_seats, :rows_should_be_even

  has_many :tables
  has_many :seatings, :through => :tables
  has_many :users, :through => :seatings
  
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

  # このイベントで自由席になったユーザのリストを返す
  def excluded_users
    User.all - users
  end
  
  def plan_seating(priorities)
    case style
    when "tables"
      plan_seating_tables(priorities)
    when "rows"
      plan_seating_rows(priorities)
    end
  end

  protected

  #########################################################
  # Seat planning
  #########################################################

  def plan_seating_tables(priorities)
    h = initial_seating_tables 
    best = plan_seating_impl(h, priorities)
    best = best.group_by{|user, table| table }.values
    save_seatings(best)
  end 
  
  def plan_seating_rows(priorities)
    # 1. ４人テーブルだと思って分割する
    h = Hash.new
    User.included.shuffle.each_with_index{|u, i| h[u.id] = i / 4 }
    best = plan_seating_impl(h, priorities)
    
    # 2. 4人テーブルを、なるべくテーブルを越えての会話が成り立たなくなるように並べる
    best = best.group_by{|user, table| table }.values

    a = Array.new
    min = best.min_by{|us| us.length }
    best.remove(min)
    a << min
    unless best.empty?
      min = best.min_by {|us| tables_matching(min, us, priorities) }
      best.remove(min)
      a << min
    end

    # TODO 3. 4人の中での並び順を最適化する

    # 4. 席決め結果を記録する
    save_seatings(a.reverse)
  end

  # example setting: 4users x 2 + 2users x 4 = 16
  # 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 (user index)
  # 0 1 0 1 0 1 0 1 2 3  4   5    2   3   4   5 (initial table number)
  def initial_seating_tables
    sn1 = size1 * number1
    h = Hash.new
    users = User.included.shuffle
    users.take(sn1).each_with_index{|u, i| h[u.id] = i % number1 }
    users.drop(sn1).each_with_index{|u, i| h[u.id] = i % number2 + number1 }
    h
  end
  
  def plan_seating_impl(h, priorities)
    best = h

    excluded_ids = User.excluded.collect{|u| u.id }
    pairs = priorities.sort{|a, b| b[1] <=> a[1] }.map{|pair, score| pair }.select{|pair| (pair & excluded_ids).empty? }
    satisfied, unsatisfied = pairs.partition{|pair| sametable?(h, pair[0], pair[1]) }
    
    until unsatisfied.empty?
      best, max, improved = h, total_priority(satisfied, priorities), false

      unsatisfied.each{|pair|
        # 希望に従って入れ替える
        u1, u2 = pair[0], pair[1]
        if not sametable?(h, u1, u2)
          users1 = h.select{|u, table| table == h[u1] && u != u1 }.map{|u, _| u } # u1 と同じテーブルの人々
          users2 = h.select{|u, table| table == h[u2] && u != u2 }.map{|u, _| u } # u2 と同じテーブルの人々
          
          if wantedscore(u1, users1, priorities) > wantedscore(u2, users2, priorities) # 元の部屋にそのままいる方が良い方を残す
            swap(h, u2, users1.min{|u| wantedscore(u, users1, priorities) })
          else
            swap(h, u1, users2.min{|u| wantedscore(u, users2, priorities) })
          end
        end
        
        # 入れ替え結果を評価する
        score = total_priority(pairs.select{|pair| sametable?(h, pair[0], pair[1])}, priorities)
        best, max, improved = h.clone, score, true if score > max
      }

      satisfied, unsatisfied = pairs.partition{|pair| sametable?(best, pair[0], pair[1]) }
      h = best
      break unless improved # 改善が見られなかったら、全ての希望を満たしていなくても探索終了
    end

    best
  end
  
  def save_seatings(groups)
    groups.each{|us|
      tables.create(:user_ids => us.map{|u, t| u} )
    }
  end
  
  #########################################################
  # Seat planning helper methods
  #########################################################
    
  def sametable?(h, u1, u2)
    h[u1] == h[u2]
  end

  def total_priority(pairs, priorities)
    pairs.inject(0){|sum, pair| sum + priorities[pair] }
  end
  
  def wantedscore(user, users, priorities)
    users.inject(0){|result, u| result + priorities[[u, user].sort] }
  end
  
  def tables_matching(users1, users2, priorities)
    users1.product(users2).inject(0){|sum, us| sum + priorities[us.sort] }
  end

  def swap(h, u1, u2)
    temp = h[u1]
    h[u1] = h[u2]
    h[u2] = temp
  end

  #########################################################
  # Validation methods
  #########################################################

  def has_enough_seats
    if size1 * number1 + size2 * number2 < User.count
      errors.add(:size1, "人数に対して席が不足しています")
      errors.add(:size2, "人数に対して席が不足しています")
      errors.add(:number1, "人数に対して席が不足しています")
      errors.add(:number2, "人数に対して席が不足しています")
    end
  end
  
  def rows_should_be_even
    if style == "rows" then
      errors.add(:size1, "列の長さは偶数でなければなりません") if size1 % 2 != 0
      errors.add(:number1, "列の個数は偶数でなければなりません") if number1 % 2 != 0
    end
  end
end
