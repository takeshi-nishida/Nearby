class EventsController < ApplicationController
#  http_basic_authenticate_with :name => "wiss2012", :password => "aomori338", :only => [:index]
  http_basic_authenticate_with :name => 'tnishida', :password => '3594t', :only => [:new, :create, :plan, :forget, :admin_index]

  before_action :current_user, only: [:want, :want_topic]

  def index
    @events = Event.all
#    @users = User.all
    @topics = Topic.all
    @want = Want.new
    @grouped_users = User.grouped_options_by_affiliation
    @affiliations = @grouped_users.keys.sort
  end

  def admin_index
    @events = Event.all
    @wants = Want.all
    @topics = Topic.all
  end

  def show
    @event = Event.find(params[:id])
#    @excluded_users = @event.excluded_users
#    @wants = Want.for_user
#    @satisfied, @unsatisfied = @event.partition(@wants) if @event.planned?
  end

  def new
    @event = Event.new(style: 'tables', size1: 4, number1: User.count / 4, size2: 0, number2: 0)
  end

  def create
    @event = Event.new(params.require(:event).permit(:description, :style, :size1, :number1, :size2, :number2))
    if @event.save
      redirect_to @event
    else
      render 'new'
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.forget_seating
    @event.destroy
    redirect_to :admin_index
  end

  def plan
    @event = Event.find(params[:id])
    @event.plan_seating(Want.priorities)
    redirect_to :admin_index
  end

  def forget
    @event = Event.find(params[:id])
    @event.forget_seating
    redirect_to :admin_index
  end

  def want
    @want = current_user.wants.build(params.require(:want).permit(:who_id, :wantable_id))
    @want.wantable_type = 'User'

    if @want.save
    else
      flash['alert'] = '無効な希望です'
      flash.keep
    end
      redirect_to root_url
  end

  def want_topic
    @want = current_user.wants.build(params.require(:want).permit(:wantable_id))
    @want.who = current_user
    @want.wantable_type = 'Topic'

    if @want.save
    else
    end

    redirect_to root_url
  end

  def update_exclude
    current_user.exclude = params[:exclude] ? true : false
    current_user.save
    puts current_user.exclude
    redirect_to root_url
  end

end
