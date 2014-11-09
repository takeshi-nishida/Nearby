class TopicsController < ApplicationController
  before_action :current_user, only: [:create]

  def new
    @topic = Topic.new
    @topics = Topic.all
  end
  
  def create
    @topic = Topic.create(params.require(:topic).permit(:description))
    @topic.user = current_user
    
    if @topic.save
      redirect_to root_url
    else
      render 'new'
    end
  end
end
