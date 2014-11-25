class SeatPlanner
  def initialize(event, n)
    raise 'SeatPlanner initialized with invalid params' unless event.is_a? Event and n.is_a? Integer
    @event = event
    @n = n
  end

  def plan_seating(priorities)
    raise 'Not implemented!'
  end

  protected

  # An implementation of a greedy swapping based seating algorithm
  #     h = hash mapping: user_id => table_id
  #     priorities = three hashes mapping: [u1, u2] => score, the key array of two user ids should be sorted
  def plan_seating_impl(h, priorities)
    best = h
    p_user, p_topic, p_done = priorities
    pairs = p_user.merge(p_topic){|_,v1,v2| [v1, v2].max }.sort_by{|pair, v| -v }.map{|pair, v| pair }
    unsatisfied = pairs.reject{|u1,u2| same_table?(h, u1, u2) }

    until unsatisfied.empty?
      best, max, improved = h, total_priority(h, priorities), false

      unsatisfied.shuffle.each{|u1, u2|
        next if same_table?(h, u1, u2)
        prev_h = h.clone

        users1 = users_together(h, u1)
        users2 = users_together(h, u2)

        next if users1.empty? && users2.empty?

        if wanted_score(u1, users1, priorities) > wanted_score(u2, users2, priorities) # 元の部屋にそのままいる方が良い方を残す
          unless users1.empty?
            temp_users = users1 + [u2]
            swap(h, u2, users1.max{|u| table_priority(temp_users - [u], priorities) }) #u2 が users1 の誰か (u1以外) と入れ替わる
          end
        else
          unless users2.empty?
            temp_users = users2 + [u1]
            swap(h, u1, users2.max{|u| table_priority(temp_users - [u], priorities) }) # u1 が users2 の誰か (u2以外) と入れ替わる
          end
        end

        # 入れ替え結果を評価する
        score = total_priority(h, priorities)
        if score > max
          best, max, improved = h.clone, score, true
        else
          h = prev_h
        end
      }

      unsatisfied = pairs.reject{|u1, u2| same_table?(best, u1, u2) }
      if improved
        h = best
      else
        break # 改善が見られなかったら、全ての希望を満たしていなくても探索終了
      end
    end

    return best,  total_priority(best, priorities)
  end

  def save_seatings(groups)
    groups.each{|us|
      @event.tables.create(:user_ids => us.map{|u, t| u} )
    }
  end

  #########################################################
  # Seat planning helper methods
  #########################################################

  def same_table?(h, user1, user2)
    h[user1] == h[user2]
  end

  # user と同じテーブルにいるユーザ全員 (user を除く)
  def users_together(h, user)
    h.select{|u, table| table == h[user] && user != u }.map{|u, _| u }
  end

  # u1 と u2 が同じテーブルに着いた場合の評価値
  def pair_priority(u1, u2, priorities)
    pair = [u1, u2].sort
    priorities.map{|p| p[pair] }.reduce(:+)
  end

  # あるテーブルの合計評価値 (users: 同じテーブルに着いたユーザ)
  def table_priority(users, priorities)
    return 0 unless users.length > 1
    p_user, p_topic, p_done = priorities
    too_satisfied = Hash.new(0)
    users.permutation(2).group_by{|u1, u2| u1 }.each{|u, pairs|
      too_satisfied[u] = pairs.count{|pair| p_user.include?(pair.sort) } > 4 # 人希望が叶いすぎているのはダメ！
    }
    users.combination(2).map{|u1, u2|
      key = [u1, u2].sort
      p_topic[key] + p_done[key] + ((too_satisfied[u1] || too_satisfied[u2]) ? 0 : p_user[key])
    }.reduce(:+)
  end

  # 決めた席全体の合計評価値
  def total_priority(h, priorities)
    h.group_by{|u, t| t}.map{|table, users| table_priority(users.map{|u,t| u}, priorities) }.reduce(:+)
  end

  # user が users の中にいることの評価値
  def wanted_score(user, users, priorities)
    users.length > 0 ? users.map{|u| pair_priority(u, user, priorities) }.reduce(:+) : 0
  end

  def swap(h, u1, u2)
    temp = h[u1]
    h[u1] = h[u2]
    h[u2] = temp
  end
end