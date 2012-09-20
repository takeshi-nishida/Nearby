class EventsController < ApplicationController
  http_basic_authenticate_with :name => "tnishida", :password => "3594t", :only => [:show, :new]

  before_filter :current_user, only: [:want, :want_topic]
  
  def index
    @events = Event.find(:all)
    @users = User.find(:all)
    @topics = Topic.find(:all)
    @want = Want.new
  end

  def show
    @event = Event.find(params[:id])
    @users  = User.find(:all)
    @wants = Want.for_user
#    @event.forget_seating
    @priorities = Want.priorities
    @event.plan_seating(@users, @priorities) unless @event.planned?
    @satisfied, @unsatisfied = @event.partition(@wants)
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
  
  def want_topic
    @want = current_user.wants.build(params[:want])
    @want.who = current_user
    @want.wantable_type = "Topic"
    
    if @want.save
    else
    end
    
    redirect_to root_url
  end
end
