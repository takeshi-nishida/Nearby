module ApplicationHelper
  PARTICIPATION_TYPES = [ "登壇発表", "デモ・ポスター発表", "PCメンバー", "学生ボランティア", "参加のみ" ]
  
  def participation_types
    PARTICIPATION_TYPES
  end
end
