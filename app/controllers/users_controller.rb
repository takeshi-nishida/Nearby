class UsersController < ApplicationController
  http_basic_authenticate_with :name => 'tnishida', :password => '3594t'
  
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end
  
  def create
#    @user = User.new(params[:user])
    @user = User.new(user_params)
    @user.insecure_password = params[:user][:password] # VERY BAD! (just for now)
    if @user.save
      redirect_to root_url, notice: 'Signed up!'
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    # @user.update(params[:user])
    @user.update(user_params)
    redirect_to @user
  end
    
  def new_csv
    @users = User.all
  end
  
  def import_csv
    require 'csv'
    require 'kconv'
    
    s = params[:csv].read
#    s.force_encoding("Shift_JIS")

    CSV.parse(s, headers: true) do |row|
      @user = User.new(
        name: row['name'],
        email: row['email'],
        password: row['password'],
        password_confirmation: row['password'],
        insecure_password: row['password'], # VERY BAD! (just for now...)
        furigana: row['furigana'],
        affiliation: row['affiliation'],
        category: row['category'],
        sex: row['sex'].to_i
      )
      @user.save
    end
    
    redirect_to action: 'index'
  end
  
  def invite
    @users = User.all
    @users.each{|user| AnnounceMailer.invite(user).deliver }
    render :index
  end

  protected

  def user_params
    params.require(:user).permit(:name, :email, :affiliation, :sex, :category, :password, :password_confirmation, :password_digest)
  end
end
