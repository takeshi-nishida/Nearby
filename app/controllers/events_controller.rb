class EventsController < ApplicationController
  http_basic_authenticate_with :name => "tnishida", :password => "3594t", :only => [:show, :new]

  before_filter :current_user, only: [:want]
  
  def index
    @events = Event.find(:all)
    @users = User.find(:all)
    @want = Want.new
  end

  def show
    @event = Event.find(params[:id])
    @users  = User.find(:all)
    @wants = Want.find(:all)

    # 席を決める
    # まずは適当に割り振る TODO: 適当にシャッフルする
    @n = @event.groupsize #(@users.size.to_f / @event.groupsize).ceil
    h = Hash.new
    @users.each_with_index{|u, i| h[u] = i % @n }
    @satisfied, @unsatisfied = @wants.partition{|w| h[w.who] == h[w.wantable] }
    
    until @unsatisfied.empty?
      best, max, improved = h, total_priority(@satisfied), false

      @unsatisfied.sort{|w1, w2| w1.priority <=> w2.priority }.each{|w|
        # 希望に従って入れ替える
        if h[w.who] != h[w.wantable]
          us1 = h.select{|u, table| table == h[w.who] && u != w.who }.map{|u, _| u }
          us2 = h.select{|u, table| table == h[w.wantable] && u != w.wantable }.map{|u, _| u }
          
          if wantedscore(w.who, us1) > wantedscore(w.wantable, us2) # 元の部屋にそのままいる方が良い方を残す
            swap(h, w.wantable, us1.min{|u| wantedscore(u, us1) })
          else
            swap(h, w.who, us2.min{|u| wantedscore(u, us2) })
          end
        end
        
        # 入れ替え結果を評価する
        score = total_priority(@wants.select{|w| h[w.who] == h[w.wantable] })
        best, max, improved = h.clone, score, true if score > max
      }

      @satisfied, @unsatisfied = @wants.partition{|w| best[w.who] == best[w.wantable] }
      h = best
      break unless improved # 改善が見られなかったら、全ての希望を満たしていなくても探索終了
    end
    
    @score = @satisfied.inject(0){|result, w| result + w.priority }    
    @h = best.group_by{|user, table| table }
    # TODO: DBに記録する
  end

  def new
    @event = Event.new
  end
  
  def create
    @event = Event.new(params[:event])
    if @event.save
      redirect_to @event
    else
      render 'new'
    end
  end
  
  def want
    @want = current_user.wants.build(params[:want])
    @want.wantable_type = "User"
    
    if @want.save
    else
    end
    
    redirect_to root_url
  end
  
  protected
  
  def total_priority(wants)
    wants.inject(0){|sum, w| sum + w.priority }
  end
  
  def wantedscore(user, users)
    users.inject(0){|result, u| result + pair_priority(u, user) }
  end
  
  def pair_priority(u1, u2)
    wants = Want.where(who_id: u1.id, wantable_id: u2.id) + Want.where(who_id: u2.id, wantable_id: u1.id)
    total_priority(wants)
    # might better cache the score
  end
  
  def swap(h, u1, u2)
    require "kconv"
    puts "#{u1.name.tosjis} <=> #{u2.name.tosjis}"
    temp = h[u1]
    h[u1] = h[u2]
    h[u2] = temp
  end
end
