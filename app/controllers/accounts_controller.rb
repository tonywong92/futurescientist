class AccountsController < ApplicationController

  def new
    if Account.find(:all).empty?
      create_admin
    else
      if session[:account] && session[:account].admin
        create_admin
      else
        @user = User.new(params[:user])
        @account = Account.new(params[:account])
        @user.phone_number = normalize_phone(@user.phone_number)
        @all_skills = Skill.find(:all)
      end
    end
    if request.post?
      @user.account = @account
      save_account
      return '/accounts/new'
    end
    render '/accounts/new'
  end
  
  def create
    new
  end

  def create_admin
    @user = User.new(params[:user])
    @account = Account.new(params[:account])
    @all_skills = Skill.find(:all)
    @account.admin = true
  end
  
  def save_account
    if @account.save and @user.save
      flash[:notice] = 'You have successfully created an account'
      redirect_to problems_path
    else
      flash[:error] = 'There was a problem with creating your account'
      render '/accounts/new'
    end
  end
  
  def show
    render '/accounts/login_form'
  end
  
  def login
    @account = Account.find_by_account_name(params[:account][:account_name])
    if @account.nil?
      flash[:error] = 'No such account exists'
      render '/accounts/login_form'
    else
      validate_password
    end
  end
  
  def logout
    reset_session
    flash[:notice] = "You have successfully logged out"
    redirect_to problems_path
  end
  
  def validate_password
    if @account.password == params[:account][:password]
      session[:account] = @account
      flash[:notice] = "Welcome, #{@account.account_name}"
      redirect_to problems_path
    else
      flash[:error] = 'Your password is incorrect'
      render '/accounts/edit'
    end
  end
  
  def edit
    render '/accounts/edit'
  end

  def update
    #todo: find out who is making the update call
    @account = Account.find_by_account_name('foobar')
    @account.update_attributes!(:email => params[:email][:address])
    redirect_to '/accounts/edit'
  end

  def changepass
    @account = Account.find_by_account_name('foobar')
    if params[:password_new][:new] == params[:reenter][:pass] 
      @account.update_attributes!(:password => params[:password_new][:new])
      redirect_to '/accounts/edit'
    else 
      redirect_to '/accounts/edit'
    end
  end
  
  def normalize_phone phone_number
    return '+' + phone_number.gsub('(','').gsub(')','').gsub('-','').gsub('+','')
  end
  
end
