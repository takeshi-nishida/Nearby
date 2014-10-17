class SessionsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])
#    user = User.find(params[:user_id])
    
    if user and user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: "Logged in successfully."
    else
      flash[:alert] = "Login failed."
      flash.keep
      redirect_to root_url
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out."
  end
  
end
