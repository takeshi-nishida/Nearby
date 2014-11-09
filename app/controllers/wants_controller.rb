class WantsController < ApplicationController
  before_action :current_user, only: [:destroy]
  before_action :require_user

  def destroy
    if @user == current_user
      @want = @user.wants.find(params[:id])
      @user.wants.delete(@want)
    end
    redirect_to :root
  end
  
  private
  
  def require_user
    @user = User.find(params[:user_id])
  end
end
