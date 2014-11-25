class Event < ActiveRecord::Base
  validate :has_enough_seats, :rows_should_be_even

  has_many :tables, :dependent => :delete_all
  has_many :seatings, :through => :tables,  :dependent => :delete_all
  has_many :users, :through => :seatings
  
  def planned?
    !tables.empty?
  end
  
  # 重いので注意
  def partition(wants)
    wants.partition{|w|
      case w.wantable_type
      when 'User'
#        s1 = seatings.find_by_user_id(w.who.id)
#        s2 = seatings.find_by_user_id(w.wantable.id)
#        s1 && s2 && s1.table == s2.table
        tables.any?{|table| (table.users & [w.who, w.wantable]).size == 2 }
      when 'Topic'
        tables.any?{|table| table.popular_topics.include?(w.wantable) }
      end
    }
  end
  
  def forget_seating
    tables.clear
#    seatings.clear
  end

  # このイベントで自由席になったユーザのリストを返す
  def excluded_users
    User.all - users # TODO: better written by join?
  end

  def plan_seating(priorities)
    SEAT_PLANNERS[style].new(self, 1).plan_seating(priorities) unless planned?

    # unless planned?
    #   # case style
    #   #   when 'tables'
    #   #     plan_seating_tables(priorities)
    #   #   when 'rows'
    #   #     plan_seating_rows(priorities)
    #   # end
    # end
  end

  protected

  SEAT_PLANNERS = { 'tables' => TablesSeatPlanner, 'rows' => RowsSeatPlanner, 'zashiki' => ZashikiSeatPlanner }

  #########################################################
  # Seat planning
  #########################################################

  # def plan_seating_tables(priorities)
  #   plans = Array.new
  #   1.times{ plans << plan_seating_impl(initial_seating_tables, priorities) }
  #   best, bestscore = plans.max_by { |plan, score|  score }
  #   best = best.group_by{|user, table| table }.values.sort_by{|table| table.size }
  #   save_seatings(best)
  # end
  
  # def plan_seating_rows(priorities)
  #   plans = Array.new
  #   1.times{ plans << plan_seating_impl(initial_seating_rows, priorities) }
  #   best, bestscore = plans.max_by { |plan, score|  score }
  #
  #   # 2. 4人テーブルを、なるべくテーブルを越えての会話が成り立たなくなるように並べる
  #   best = best.group_by{|user, table| table }.values
  #
  #   a = Array.new
  #   min = best.min_by{|us| us.length }
  #   best.delete(min)
  #   a << min
  #   until best.empty?
  #     min = best.min_by {|us| tables_matching(min, us, priorities) }
  #     best.delete(min)
  #     a << min
  #   end
  #
  #   # 4. 席決め結果を記録する
  #   save_seatings(a.reverse)
  # end

#   # example setting: 4users x 2 + 2users x 4 = 16
#   # 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 (user index)
#   # 0 1 0 1 0 1 0 1 2 3  4   5    2   3   4   5 (initial table number)
#   def initial_seating_tables
#     sn1 = size1 * number1
#     h = Hash.new
#     users = User.included.shuffle
# #    users = User.included.sort_by{|u| u.popularity } # 希望されていない順に並べる（人気者が size2 の方に入るように　size2 > size1 と仮定）
#     users.take(sn1).each_with_index{|u, i| h[u.id] = i % number1 }
#     users.drop(sn1).each_with_index{|u, i| h[u.id] = i % number2 + number1 }
#     h
#   end
  
  # def initial_seating_rows
  #   h = Hash.new
  #   User.included.shuffle.each_with_index{|u, i| h[u.id] = i / 4 } # 1. ４人テーブルだと思って分割する
  #   h
  # end
  
  # def plan_seating_impl(h, priorities)
  #   best = h
  #   p_user, p_topic, p_done = priorities
  #   pairs = p_user.merge(p_topic){|_,v1,v2| [v1, v2].max }.sort_by{|pair, v| -v }.map{|pair, v| pair }
  #   unsatisfied = pairs.reject{|u1,u2| sametable?(h, u1, u2) }
  #
  #   until unsatisfied.empty?
  #     best, max, improved = h, total_priority(h, priorities), false
  #
  #     unsatisfied.shuffle.each{|u1, u2|
  #       next if sametable?(h, u1, u2)
  #       prevh = h.clone
  #
  #       users1 = users_together(h, u1)
  #       users2 = users_together(h, u2)
  #
  #       next if users1.empty? && users2.empty?
  #
  #       if wantedscore(u1, users1, priorities) > wantedscore(u2, users2, priorities) # 元の部屋にそのままいる方が良い方を残す
  #         unless users1.empty?
  #           temp_users = users1 + [u2]
  #           swap(h, u2, users1.max{|u| table_priority(temp_users - [u], priorities) }) #u2 が users1 の誰か (u1以外) と入れ替わる
  #         end
  #       else
  #         unless users2.empty?
  #           temp_users = users2 + [u1]
  #           swap(h, u1, users2.max{|u| table_priority(temp_users - [u], priorities) }) # u1 が users2 の誰か (u2以外) と入れ替わる
  #         end
  #       end
  #
  #       # 入れ替え結果を評価する
  #       score = total_priority(h, priorities)
  #       if score > max
  #         best, max, improved = h.clone, score, true
  #       else
  #         h = prevh
  #       end
  #     }
  #
  #     unsatisfied = pairs.reject{|u1, u2| sametable?(best, u1, u2) }
  #     if improved
  #       h = best
  #     else
  #       break # 改善が見られなかったら、全ての希望を満たしていなくても探索終了
  #     end
  #   end
  #
  #   return best,  total_priority(best, priorities)
  # end
  
  # def save_seatings(groups)
  #   groups.each{|us|
  #     tables.create(:user_ids => us.map{|u, t| u} )
  #   }
  # end
  
  # #########################################################
  # # Seat planning helper methods
  # #########################################################
  #
  # def sametable?(h, user1, user2)
  #   h[user1] == h[user2]
  # end
  #
  # # user と同じテーブルにいるユーザ全員 (user を除く)
  # def users_together(h, user)
  #   h.select{|u, table| table == h[user] && user != u }.map{|u, _| u }
  # end
  #
  # # u1 と u2 が同じテーブルに着いた場合の評価値
  # def pair_priority(u1, u2, priorities)
  #   pair = [u1, u2].sort
  #   priorities.map{|p| p[pair] }.reduce(:+)
  # end
  #
  # # あるテーブルの合計評価値 (users: 同じテーブルに着いたユーザ)
  # def table_priority(users, priorities)
  #   return 0 unless users.length > 1
  #   p_user, p_topic, p_done = priorities
  #   too_satisfied = Hash.new(0)
  #   users.permutation(2).group_by{|u1, u2| u1 }.each{|u, pairs|
  #     too_satisfied[u] = pairs.count{|pair| p_user.include?(pair.sort) } > 4 # 人希望が叶いすぎているのはダメ！
  #   }
  #   users.combination(2).map{|u1, u2|
  #     key = [u1, u2].sort
  #     p_topic[key] + p_done[key] + ((too_satisfied[u1] || too_satisfied[u2]) ? 0 : p_user[key])
  #   }.reduce(:+)
  # end
  #
  # # 決めた席全体の合計評価値
  # def total_priority(h, priorities)
  #   h.group_by{|u, t| t}.map{|table, users| table_priority(users.map{|u,t| u}, priorities) }.reduce(:+)
  # end
  #
  # # user が users の中にいることの評価値
  # def wantedscore(user, users, priorities)
  #   users.length > 0 ? users.map{|u| pair_priority(u, user, priorities) }.reduce(:+) : 0
  # end
  #
  # # used in plan_seating_rows
  # def tables_matching(users1, users2, priorities)
  #   users1.product(users2).map{|u1,u2| pair_priority(u1,u2, priorities) }.reduce(:+)
  # end
  #
  # def swap(h, u1, u2)
  #   temp = h[u1]
  #   h[u1] = h[u2]
  #   h[u2] = temp
  # end

  #########################################################
  # Validation methods
  #########################################################

  def has_enough_seats
    if size1 * number1 + size2 * number2 < User.count
      errors.add(:size1, 'not enough seats compared to participants')
      errors.add(:size2, 'not enough seats compared to participants')
      errors.add(:number1, 'not enough seats compared to participants')
      errors.add(:number2, 'not enough seats compared to participants')
    end
  end
  
  def rows_should_be_even
    if style == 'rows'
      errors.add(:size1, 'row size has to be even') if size1 % 2 != 0
      errors.add(:number1, 'row number has to be even') if number1 % 2 != 0
    end
  end
end
