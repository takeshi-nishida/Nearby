class UsersController < ApplicationController
#  http_basic_authenticate_with :name => 'tnishida', :pass => '3594t', :only => [:index, :show, :new, :new_csv]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_url, notice: "Signed up!"
    else
      render "new"
    end
  end
  
  def new_csv
    @users = User.find(:all)
  end
  
  def import_csv
    require 'csv'
    require 'kconv'
    
    s = params[:csv].read
    s.force_encoding("Shift_JIS")

    CSV.parse(s, headers: true) do |row|
      @user = User.new(
        name: row["name"],
        password: row["password"],
        password_confirmation: row["password_confirmation"]
      )
      @user.save
    end
    
    redirect_to action: "new_csv"
  end
end
