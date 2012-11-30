class WantsController < ApplicationController
  before_filter :current_user, only: [:destroy]
  before_filter :require_user

  def destroy
    if @user == current_user then
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
