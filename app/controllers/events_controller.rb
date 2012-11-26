class EventsController < ApplicationController
  http_basic_authenticate_with :name => "tnishida", :password => "3594t", :only => [:show, :new, :plan, :forget]

  before_filter :current_user, only: [:want, :want_topic]
  
  def index
    @events = Event.find(:all)
    @users = User.find(:all)
    @topics = Topic.find(:all)
    @want = Want.new
    @grouped_users = User.grouped_options_by_affiliation
  end
  
  def admin_index
    @events = Event.find(:all)
  end

  def show
    @event = Event.find(params[:id])
    @excluded_users = @event.excluded_users
    @wants = Want.for_user
    @satisfied, @unsatisfied = @event.partition(@wants) if @event.planned?
  end

  def new
    @event = Event.new(style: "tables", size1: 4, number1: User.count / 4, size2: 0, number2: 0)
  end
  
  def create
    @event = Event.new(params[:event])
    if @event.save
      redirect_to @event
    else
      render 'new'
    end
  end
  
  def plan
    @event = Event.find(params[:id])
    unless @event.planned?
      @priorities = Want.priorities
      @event.plan_seating(@priorities)
    end
    redirect_to :admin_index
  end
  
  def forget
    @event = Event.find(params[:id])
    @event.forget_seating
    redirect_to :admin_index
  end
  
  def want
    @want = current_user.wants.build(params[:want])
    @want.wantable_type = "User"
    
    if @want.save
    else
    end
    
    redirect_to root_url
  end
  
  def want_topic
    @want = current_user.wants.build(params[:want])
    @want.who = current_user
    @want.wantable_type = "Topic"
    
    if @want.save
    else
    end
    
    redirect_to root_url
  end 
  
  def update_exclude
    current_user.exclude = params[:exclude]
    current_user.save
    puts current_user.exclude
    redirect_to root_url
  end

end
