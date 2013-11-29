# -*- coding: utf-8 -*-

module EventsHelper
  
  def event_details(e)
    h1 = {"tables" => "テーブル席", "rows" => "座敷"}
    h2 = {"tables" => "個", "rows" => "列"}
    s = "#{h1[e.style]} ("
    s << "#{e.size1}人 × #{e.number1}#{h2[e.style]}" if e.number1 > 0
    s << " + #{e.size2}人 × #{e.number2}#{h2[e.style]}" if e.number2 > 0
    s << "), 席決め人数: #{e.users.count}人"
  end

  def human_readable_want(w)
    case w.wantable_type
    when "User"
      "#{w.who.name} さんが #{w.wantable.name} さんが近くの席になれたらいいな"
    when "Topic"
      "#{w.wantable.description if w.wantable} の話がしたい"
    end
  rescue
    "error: #{w.who} / #{w.wantable}"
  end
        
  def plan_button_for(event)
    if event.planned? then
      button_to "決めた席をなかったことにする", forget_event_path(event)
    else
      button_to "席を決める", plan_event_path(event)
    end
  end
  
  def zasiki_style_name(i)
    i / 2 % 2 == 0 ? "even-col" : "odd-col"
  end

  # 4人分割の配列から座敷用の列を生成する
  def tables_to_rows(event)
    # 1. 4人未満のテーブルを4人に揃える
    a = event.tables.collect{|table| fill_to(table.users, 4) }

    # 2. 座敷の席数に配列の長さを揃える
    a = fill_to(a, event.size1 * event.number1 / 4)
    
    # 3. 転置の下準備をする
    b = Array.new
    a.each_slice(event.size1 / 2){|slice| b << slice }

    # 4. 転置して、各テーブルから2人を１行に、残りの2人を次の行に入れる
    c = Array.new
    b.transpose.each{|row|
      c << row.collect{|users| users ? users[0,2] : [nil] * 2}.flatten
      c << row.collect{|users| users ? users[2,2] : [nil] * 2}.flatten
    }
    c
  end
  
  # 配列 a の長さを n に揃える（不足分は nil で埋める）
  def fill_to(a, n)
    a.length < n ? a + [nil] * (n - a.length) : a
  end
end
