class ZashikiSeatPlanner < SeatPlanner

  def plan_seating(priorities)
    plans = Array.new
    @n.times{ plans << plan_seating_impl(initial_seating_rows, priorities) }
    best, _ = plans.max_by { |plan, score|  score }

    # 2. 2人テーブルを、希望の叶っている順に並べる
    # 理由：希望がかなっている人どうしが端っこに行かないようにするため（端っこの処理で離れてしまうことがある）
    best = best.group_by{|user, table| table }.values.sort_by { |users| users.length > 1 ? table_priority(users.map{|u,t| u }, priorities) : -10000 }

    # 3. 席決め結果を記録する
    save_seatings(best.reverse)
  end

  protected

  # 1. 2人テーブルだと思って分割する
  def initial_seating_rows
    h = Hash.new
    User.included.shuffle.each_with_index{|u, i| h[u.id] = i / 2 }
    h
  end
end