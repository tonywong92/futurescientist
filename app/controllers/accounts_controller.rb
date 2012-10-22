class AccountsController < ApplicationController

  def new
    @user = User.new(params[:user])
    @account = Account.new(params[:account])
    @all_skills = Skill.find(:all)
    if request.post?
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