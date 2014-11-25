class TablesSeatPlanner < SeatPlanner
  def plan_seating(priorities)
    plans = Array.new
    @n.times{ plans << plan_seating_impl(initial_seating_tables, priorities) }
    best, _ = plans.max_by { |plan, score|  score }
    best = best.group_by{|user, table| table }.values.sort_by{|table| table.size }
    save_seatings(best)
  end

  protected

  # example setting: 4users x 2 + 2users x 4 = 16
  # 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 (user index)
  # 0 1 0 1 0 1 0 1 2 3  4   5    2   3   4   5 (initial table number)
  def initial_seating_tables
    sn1 =@event.size1 * @event.number1
    h = Hash.new
    users = User.included.shuffle
#    users = User.included.sort_by{|u| u.popularity } # 希望されていない順に並べる（人気者が size2 の方に入るように　size2 > size1 と仮定）
    users.take(sn1).each_with_index{|u, i| h[u.id] = i % @event.number1 }
    users.drop(sn1).each_with_index{|u, i| h[u.id] = i % @event.number2 + @event.number1 }
    h
  end

end