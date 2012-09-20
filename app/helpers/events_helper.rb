# -*- coding: utf-8 -*-

module EventsHelper
  def human_readable_want(w)
    case w.wantable_type
    when "User"
      "#{w.who.name} さんが #{w.wantable.name} さんが近くの席になれたらいいな"
    when "Topic"
      "#{w.wantable.description} の話がしたい"
    end
  end
end
