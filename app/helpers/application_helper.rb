module ApplicationHelper
#  PARTICIPATION_TYPES = %w(登壇発表 デモ・ポスター発表 PCメンバー 学生ボランティア 参加のみ)
  PARTICIPATION_TYPES = %w(スポンサー 招待デモ発表者 発表のある学生 一般もしくは発表のない学生 招待講演者)

  def participation_types
    PARTICIPATION_TYPES
  end
end
