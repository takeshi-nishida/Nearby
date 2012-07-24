class SessionsController < ApplicationController
  def create
    user = User.find(params[:user_id])
    
    if user and user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: "Logged in successfully."
    else
      flash.now.alert = "Login failed."
      render "new"
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out."
  end
  
end
