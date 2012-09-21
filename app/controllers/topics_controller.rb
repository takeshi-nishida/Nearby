class TopicsController < ApplicationController
  before_filter :current_user, only: [:create]

  def new
    @topic = Topic.new
    @topics = Topic.find(:all)
  end
  
  def create
    @topic = Topic.create(params[:topic])
    @topic.user = current_user
    
    if @topic.save
      redirect_to root_url
    else
      render "new"
    end
  end
end
