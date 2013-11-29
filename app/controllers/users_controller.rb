class UsersController < ApplicationController
  http_basic_authenticate_with :name => 'tnishida', :password => '3594t'
  
  def index
    @users = User.find(:all)
  end

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
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    redirect_to @user
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
        email: row["email"],
        password: row["password"],
        password_confirmation: row["password_confirmation"],
        furigana: row["furigana"],
        affiliation: row["affiliation"],
        category: row["category"],
        sex: row["sex"].to_i
      )
      @user.save
    end
    
    redirect_to action: "new_csv"
  end
end
