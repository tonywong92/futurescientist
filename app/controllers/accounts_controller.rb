class AccountsController < ApplicationController

  def new
    @user = User.new
    @user.attributes = params[:user]
    @account = Account.new
    @account.attributes = params[:account]
    if request.post?
      @user.account = @account
      save_account
      return
    end
    render 'users/new'
  end
  
  def save_account
    if @account.save! and @user.save!
      flash[:notice] = 'You have successfully created an account'
    else
      flash[:error] = 'There was a problem with creating your account'
    end
    render 'index'
  end
  
end