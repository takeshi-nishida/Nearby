class ApplicationController < ActionController::Base
  protect_from_forgery
  
  force_ssl if: :ssl_configured?


  private

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue
      session[:user_id] = nil
    end
  end

  helper_method :current_user

  def ssl_configured?
    !Rails.env.development?
  end
end
