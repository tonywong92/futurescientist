class AccountsController < ApplicationController

  def new
    @user = User.new
    @account = Account.new
    @all_skills = Skill.find(:all)
    if request.post?
      @account.email = params[:account][:email]
      @account.account_name = params[:account][:account_name]
      @account.password = params[:account][:password]
      @account.skills = params[:account][:skills]
      @user.location = params[:user][:location]
      @user.name = params[:user][:name]
      @user.phone_number = params[:user][:phone_number]
      puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
      puts @account.attributes[:name]
      puts @account.attributes[:password]
      @user.account = @account
      save_account
      return
    end
    render 'accounts/new'
  end
  
  def create
    new
  end
  
  def save_account
    if @account.save! and @user.save!
      flash[:notice] = 'You have successfully created an account'
    else
      flash[:error] = 'There was a problem with creating your account'
    end
    redirect_to problems_path
  end
  
end