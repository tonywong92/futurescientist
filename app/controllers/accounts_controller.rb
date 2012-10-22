class AccountsController < ApplicationController

  def new
    @user = User.new
    @user.attributes = params[:account]
    if request.post?
      save_user
      return
    end
    render 'users/new'
  end
  
  def save_user
    if @user.save!
      flash[:notice] = 'You have successfully created an account'
    else
      flash[:error] = 'There was a problem with creating your account'
    end
    render 'index'
  end
  
end