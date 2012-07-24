class EventsController < ApplicationController
#  http_basic_authenticate_with :name => "tnishida", :pass => "3594t", :only => [:show, :new]

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

    # 1. まずは適当に割り振る
    @n = @event.groupsize #(@users.size.to_f / @event.groupsize).ceil
    best = h = Hash.new
    @users.each_with_index{|u, i| h[u] = i % @n }
    
    @satisfied, @unsatisfied = @wants.partition{|w| h[w.who] == h[w.wantable] }
    
    @unsatisfied.each{|w|
      # 2. 希望に従って入れ替える
      if h[w.who] != h[w.wantable]
        us1 = h.select{|u, table| table == h[w.who] && u != w.who }.map{|u, _| u }
        us2 = h.select{|u, table| table == h[w.wantable] && u != w.wantable }.map{|u, _| u }
        
        if wantedcount(w.who, us1) > wantedcount(w.wantable, us2)
          swap(h, w.wantable, us1.min{|u| wantedcount(u, us1) })
        else
          swap(h, w.who, us2.min{|u| wantedcount(u, us2) })
        end

#        u1, _ = h.find{|u, table| table == h[w.who] &&  !wanted_together(w.who, u) } # w.who と同じテーブルにいて、共に希望されていない人はswap可能
#        if u
#          swap(h, w.wantable, u)
#        else
#          u, _ = h.find{|u, table| table == h[w.wantable] &&  !wanted_together(w.wantable, u) } # w.wantable と同じテーブルにいて、共に希望されていない人はswap可能
#          swap(h, w.who, u) if u
#        end
      end

      # 3. 入れ替え後の割り振りで満たされていない希望を調べる
      # sat, unsat = @wants.partition{|w| h[w.who] == h[w.wantable] }

      # 4. 入れ替え後の希望適合度が入れ替え前より高ければ、記録する
      # if sat.length > @satisfied.length
      # best = h.clone
      # end
    }
    
    # TODO: 2周目に突入する
    @satisfied, @unsatisfied = @wants.partition{|w| h[w.who] == h[w.wantable] }
    @h = h.group_by{|user, table| table }
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
  
  def wantedcount(user, users)
    users.count{|u| wanted_together(u, user) }
  end
  
  def wanted_together(u1, u2)
    Want.where(who_id: u1.id, wantable_id: u2.id).exists? || Want.where(who_id: u2.id, wantable_id: u1.id).exists?
  end
  
  def swap(h, u1, u2)
    require "kconv"
    puts "#{u1.name.tosjis} <=> #{u2.name.tosjis}"
    temp = h[u1]
    h[u1] = h[u2]
    h[u2] = temp
  end
end
