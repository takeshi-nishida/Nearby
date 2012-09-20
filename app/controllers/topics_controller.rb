class TopicsController < ApplicationController
  def new
    @topic = Topic.new
    @topics = Topic.find(:all)
  end
  
  def create
    @topic = Topic.create(params[:topic])
    
    if @topic.save
      redirect_to root_url
    else
      render "new"
    end
  end
end
