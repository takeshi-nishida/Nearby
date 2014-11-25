class RowsSeatPlanner < SeatPlanner

  def plan_seating(priorities)
    plans = Array.new
    @n.times{ plans << plan_seating_impl(initial_seating_rows, priorities) }
    best, _ = plans.max_by { |plan, score|  score }

    # 2. 4人テーブルを、なるべくテーブルを越えての会話が成り立たなくなるように並べる
    best = best.group_by{|user, table| table }.values

    a = Array.new
    min = best.min_by{|us| us.length }
    best.delete(min)
    a << min
    until best.empty?
      min = best.min_by {|us| tables_matching(min, us, priorities) }
      best.delete(min)
      a << min
    end

    # 4. 席決め結果を記録する
    save_seatings(a.reverse)
  end

  protected

  def initial_seating_rows
    h = Hash.new
    User.included.shuffle.each_with_index{|u, i| h[u.id] = i / 4 } # 1. ４人テーブルだと思って分割する
    h
  end

  def tables_matching(users1, users2, priorities)
    users1.product(users2).map{|u1,u2| pair_priority(u1,u2, priorities) }.reduce(:+)
  end

end